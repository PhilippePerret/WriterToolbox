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
      # On ajuste les données au niveau du niveau de développement
      synchronise_statuts_of_pages
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

    # Les données de synchronisation
    dnar =

    # Liste des commandes qui seront envoyés par SSH
    command_scp = []
    command_mkd = []
    command_ssh = []

    serveur = serveur_ssh_boa

    # === Synchroniser les CSS ===
    # Attention, pour BOA, il faut passer les fichiers commun CSS
    folder_css = "www/objet/cnarration/lib/required/css"
    dcss = dnar[:css]
    (dcss[:synchro_required] + dcss[:distant_unknown]).each do |relpath, ncss|
      next if relpath.start_with?('./view/css/common/')
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
    folder_loc = "./data/unan/pages_semidyn/cnarration"
    folder_erb = "www/data/unan/pages_semidyn/cnarration"

    # Fichiers à ajouter et synchroniser
    (dfiles[:synchro_required] + dfiles[:distant_unknown]).each do |rpath_loc, nfile|
      pfile = File.expand_path("#{folder_loc}/#{rpath_loc}")
      pnar = "#{folder_erb}/#{rpath_loc}"
      fnar = File.dirname(pnar)
      command_mkd << fnar unless command_mkd.include?(fnar)
      command_scp << "scp -pv '#{pfile}' #{serveur}:#{pnar}"
    end

    # Fichiers ERB/IMG à détruire
    dfiles[:local_unknown].each do |rpath_loc|
      command_ssh << "  f = %q{#{folder_erb}/#{rpath_loc}}"
      command_ssh << "  File.unlink(f) if File.exist?(f)"
    end

    # Finalisation des commandes mkdir
    unless command_mkd.empty?
      command_mkd = command_mkd.collect do |dir|
        "mkdir -p #{dir}"
      end.join(";")
      command_mkd = "ssh #{serveur} \"#{command_mkd}\""
      unless mode_debuggage
        res = `#{command_mkd}`
      else
        debug "\n\ncommand_mkd: #{command_mkd}"
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
        unless mode_debuggage
          res = `#{cmd_scp}`
          debug "-> #{res.inspect}"
        else
          debug "CMD SCP JOUÉE : #{cmd_scp}"
        end
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
      unless mode_debuggage
        command_ssh = "ssh #{serveur} \"ruby -e \\\"#{command_ssh}\\\"\""
        res = `#{command_ssh}`
        debug "RETOUR BRUT : #{res.inspect}"
        if res != ""
          res = Marshal::load(res)
          debug "\n\nRETOUR DE COMMANDE SSH :\n #{res.inspect}"
        end
      else
        debug "\n\nCOMMAND SSH :\n#{command_ssh}\n\n"
      end
    end

  end

end #/<< self
end #/SynchroNarration
