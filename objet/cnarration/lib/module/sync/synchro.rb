# encoding: UTF-8
class SynchroNarration
class << self

  # Instance {Sync} de la synchronisation courante
  # Sert notamment pour récupérer les données de synchronisation
  attr_reader :isync

  # Méthode appelée par le tableau de bord de la synchronisation
  # générale pour synchroniser la collection Narration aussi bien
  # sur BOA distant que sur Narration
  #
  # Si force_online est true, on ne vérifie pas les
  # niveau de développement online, on uploade la base
  # telle quelle sur BOA et sur Icare.
  #
  # Si +synchro_icare+ est true (case à cocher), alors la
  # synchronisation est faite avec les fichiers Narration sur
  # ICARE
  #
  # +isync+
  def synchronize_all isync
    synchro_base  = param(:cb_synchronize_narration)    == 'on'
    force_online  = param(:cb_force_synchro_narration)  == 'on'
    synchro_files_narration = param(:cb_synchro_files_narration)  == 'on'

    @isync = isync
    @suivi = Array::new

    @suivi << (force_online ? "Synchronisation forcée" : "Synchronisation intelligente")

    unless force_online
      # On rappatrie la base cnarration.db du site distant
      # BOA vers local en lui donnant le nom `cnarration-distant.db`
      # pour ne pas qu'elle écrase la base existante
      download_distant_base
      # On ajuste les données au niveau du niveau de développement
      synchronise_statuts_of_pages
    end

    # On peut uploader la base du BOA et sur Icare
    if synchro_base
      @suivi << "* Upload de la base cnarration.db sur BOA et ICARE"
      upload_base
    end

    # On synchronise les fichiers sur ICARE si nécessaire
    if synchro_files_narration
      @suivi << "* Synchronisation de tous les fichiers ERB et images"
      synchronise_on_boa
      synchronise_on_icare
    end

  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    return false
  else
    return true
  end


  # ---------------------------------------------------------------------
  #   Méthodes d'upload/download
  # ---------------------------------------------------------------------

  def upload_base
    upload_base_on_boa
    upload_base_on_icare
  end

  # Charger le fichier BOA distant
  def download_distant_base
    distant_local_path.remove if distant_local_path.exist?
    cmd = "scp -p #{serveur_ssh_boa}:#{base_distant_path_boa} #{distant_local_path.expanded_path}"
    res = `#{cmd}`
    if distant_local_path.exist?
      @suivi << "Download du fichier cnarration.db distant OK"
    else
      raise "Impossible de ramener le fichier cnarration.db distant… (#{res.inspect})"
    end
  end

  # Upload de la base cnarration.db sur BOA
  def upload_base_on_boa
    cmd = "scp -p #{base_local_path.expanded_path} #{serveur_ssh_boa}:#{base_distant_path_boa}"
    res = `#{cmd}`
  end
  # Upload de la base cnarration.db sur ICARE
  def upload_base_on_icare
    cmd = "scp -p #{base_local_path.expanded_path} #{serveur_ssh_icare}:#{base_distant_path_icare}"
    res = `#{cmd}`
  end

  # Fichiers ERB et CSS NARRATION sur BOA
  def synchronise_on_boa
    @suivi << "* Synchronisation de tous les fichiers NARRATION sur BOA"
    build_commands_narration_and_execute_on :boa
    @suivi << "= Synchronisation fichier NARRATION sur BOA OK"
  end

  # Fichiers ERB et CSS NARRATION sur ICARE
  def synchronise_on_icare
    @suivi << "* Synchronisation de tous les fichiers NARRATION sur ICARE"
    build_commands_narration_and_execute_on :icare
    @suivi << "= Synchronisation fichier NARRATION sur ICARE OK"
  end

  # Procède à la construction des codes de synchronisation et
  # à la synchronisation proprement dite, sur BOA ou ICARE.
  #
  # +lieu+ {Symbol} Le lieu où doit se faire la synchronisation,
  #         :boa ou :icare. Permet de récupérer les listes dans les
  #         informations de synchronisation et de faire quelques
  #         différences de traitement.
  #
  def build_commands_narration_and_execute_on lieu

    on_boa    = lieu == :boa
    on_icare  = lieu == :icare

    dnar = isync.data_synchronisation["cnarration_#{lieu}".to_sym]

    # Liste des commandes qui seront envoyés par SSH
    command_scp = Array::new
    command_mkd = Array::new
    command_ssh = Array::new

    serveur = on_boa ? serveur_ssh_boa : serveur_ssh_icare

    # === Synchroniser les CSS ===
    # Attention, pour BOA, il faut passer les fichiers commun CSS
    folder_css = lieu == :boa ? "www/objet/cnarration/lib/required/css" : "www/ruby/_apps/Cnarration/view/css"
    dcss = dnar[:css]
    (dcss[:synchro_required] + dcss[:distant_unknown]).each do |relpath, ncss|
      next if on_boa && relpath.start_with?('./view/css/common/')
      fcss = File.expand_path(relpath)
      pnar = "./#{folder_css}/#{ncss}"
      fnar = File.dirname(pnar)
      command_mkd << fnar unless command_mkd.include?(fnar)
      command_scp << "scp -pv '#{fcss}' #{serveur}:#{pnar}"
    end

    # S'il y a des fichiers CSS à détruire online
    dcss[:local_unknown].each do |ncss|
      command_ssh << "  f = %q{./#{folder_css}/#{ncss}}"
      command_ssh << "  File.unlink(f) if File.exist?(f)"
    end

    # === Synchroniser les fichiers ERB ===
    dfiles = dnar[:files]
    folder_erb = on_boa ? "data/unan/pages_semidyn/cnarration" : "www/storage/narration/cnarration"

    # Fichiers à ajouter et synchroniser
    (dfiles[:synchro_required] + dfiles[:distant_unknown]).each do |rpath_loc, nfile|
      pfile = File.expand_path("./#{folder_erb}/#{rpath_loc}")
      pnar = "./#{folder_erb}/#{rpath_loc}"
      fnar = File.dirname(pnar)
      command_mkd << fnar unless command_mkd.include?(fnar)
      command_scp << "scp -pv '#{pfile}' #{serveur}:#{pnar}"
    end

    # Fichiers ERB/IMG à détruire
    dfiles[:local_unknown].each do |rpath_loc|
      command_ssh << "  f = %q{./#{folder_erb}/#{rpath_loc}}"
      command_ssh << "  File.unlink(f) if File.exist?(f)"
    end

    #
    # Finalisation des commandes mkdir
    #
    unless command_mkd.empty?
      command_mkd = command_mkd.collect do |dir|
        " %x(mkdir -p #{dir})"
      end.join("\n")
      command_mkd = <<-CMD
res = {error:nil}
begin
#{command_mkd}
rescue Exception => e
  res[:error] = {err_mess:e.message, err_bc: e.backtrace}
end
STDOUT.write Marshal::dump(res)
      CMD
      debug "\n\ncommand_mkd: #{command_mkd}"
      res = `ssh #{serveur} "ruby -e \\\"#{command_mkd}\\\""`
      debug "RETOUR BRUT : #{res.inspect}"
      if res != ""
        res = Marshal::load(res)
        debug "RETOUR DÉMARSHALISÉ : #{res.pretty_inspect}"
      end
    end

    #
    # Finalisation des commandes SCP
    # En fait, on fait un fichier ruby qui va créer les dossiers
    # s'ils n'existe pas puis exécuter la command scp
    #
    command_scp_final = ""
    command_scp.each do |cmd_scp|
      debug "COMMAND_SCP :\n#{cmd_scp}"
      begin
        res = `#{cmd_scp}`
        debug "-> #{res.inspect}"
      rescue Exception => e
        debug "-> ERROR : #{e.message}"
      end
    end

    #
    # Finalisation de la commande SSH
    #
    unless command_ssh.empty?
      command_ssh = command_ssh.join("\n")
      command_ssh = <<-CMD
res = {errors: nil, ok: nil}
begin
#{command_ssh}
rescue Exception => e
 res[:errors] = {err_mess: e.message, err_backtrace: e.backtrace}
 res[:ok] = false
else
 res[:ok] = true
end
STDOUT.write Marshal::dump(res)
      CMD
      command_ssh = "ssh #{serveur} \"ruby -e \\\"#{command_ssh}\\\"\""
      debug "\n\nCOMMAND SSH :\n#{command_ssh}\n\n"
      res = `#{command_ssh}`
      debug "RETOUR BRUT : #{res.inspect}"
      if res != ""
        res = Marshal::load(res)
        debug "\n\nRETOUR DE COMMANDE SSH :\n #{res.inspect}"
      end
    end

  end

end #/<< self
end #/SynchroNarration
