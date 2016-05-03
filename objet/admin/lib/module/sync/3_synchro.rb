# encoding: UTF-8
class Sync

  # = main =
  #
  # Méthode principale appelée lorsque l'on demande la synchronisation
  # des fichiers cochés.
  #
  # RETURN Rien, mais puisque la méthode détruit les fichiers
  # temporaire à la fin, la méthode principale `etat_des_lieux`
  # procèdera à un nouvel état des lieux.
  #
  def synchronize
    @suivi  ||= Array::new
    @errors ||= Array::new

    # On fait des backups en fonction des synchronisations
    # à faire
    build_backups_per_synchro

    # Toutes les synchronisation à faire

    synchronize_affiches    if param(:cb_synchronize_affiches)

    synchronize_taches      if param(:cb_synchronize_taches)

    synchronize_narration   if param(:cb_synchronize_narration) || param(:cb_synchro_files_narration)

    synchronize_scenodico   if param(:cb_synchronize_scenodico)

    synchronize_filmodico   if param(:cb_synchronize_filmodico)

    synchronize_analyses    if param(:cb_synchronize_analyses) || param(:cb_sync_analyse_files)


    # À la fin, on peut détruire tous les fichiers pour forcer
    # un prochain check. Cela entrainera l'affichage d'un
    # état des lieux (demandé par la vue erb) actualisé.
    reset_all

    if @errors.empty?
      true
    else
      error "Malheureusement, des erreurs se sont produites : #{@errors.join('<br>')}"
    end
  end

  def build_backups_per_synchro
    @suivi << "*** Backup des bases ***"
    array_backup = Array::new
    array_backup << "./database/data/site_hot.db"   if param(:cb_synchronize_taches)
    array_backup << "./database/data/cnarration.db" if param(:cb_synchronize_narration)
    array_backup << "./database/data/scenodico.db"  if param(:cb_synchronize_scenodico)
    array_backup << "./database/data/filmodico.db"  if param(:cb_synchronize_filmodico)
    array_backup << "./database/data/analyse.db"    if param(:cb_synchronize_analyses)

    folder_backup = SuperFile::new('./tmp/backups')
    folder_backup.build unless folder_backup.exist?
    folder_backup_now = folder_backup + "backup-#{Time.now.strftime('%Y%m%d-%H%M')}"
    folder_backup_now.build
    array_backup.each do |pbase|
      @suivi << "  * backup de #{pbase}"
      sfbase = SuperFile::new(pbase)
      if sfbase.exist?
        pdest = folder_backup_now + sfbase.name
        FileUtils::cp sfbase.to_s, pdest.to_s
        if pdest.exist?
          @suivi << "    BACKUP dans #{pdest} OK"
        else
          @suivi << "    PROBLÈME : Backup introuvable".in_span(class:'warning')
        end
      else
        @suivi << "    PROBLÈME : CETTE BASE EST INTROUVABLE"
      end
    end

  end

  # Relève le données de synchronisation dans le
  # fichier `sync_data_file`
  #
  # Les données de synchronisation ne sont pas à confondre avec les
  # données de check (cf. introduction)
  def data_synchronisation
    @data_synchronisation ||= begin
      synchro_data_path.exist? ? Marshal::load(synchro_data_path.read) : Hash::new
    end
  end

  # Enregistre les données de synchronisation
  # Noter que cette méthode est appelée par la méthode `build_inventory`
  # dans le module `display_methods.rb` car c'est elle qui fait l'analyse
  # des synchronisations à opérer.
  def data_synchronisation= d
    synchro_data_path.remove if synchro_data_path.exist?
    @data_synchronisation = d
    synchro_data_path.write Marshal::dump(d)
  end

  # ---------------------------------------------------------------------
  #   Méthodes de synchronisation
  # ---------------------------------------------------------------------

  # Synchronisation de la collection NARRATION sur ICARE
  #
  # Synchronise :
  #   * la base de données cnarration.db
  #   * tous les fichiers ERB
  #   * les images
  #
  def synchronize_narration
    @suivi << "* Synchronisation de la collection Narration"

    # Il faut requérir le module qui contient toutes les méthodes
    # pour synchroniser les sites
    SuperFile::new('./objet/cnarration/lib/module/sync').require
    resultat_ok = SynchroNarration::synchronize_all(self)
    @suivi << (SynchroNarration::suivi.collect{|p| "  #{p}"}.join("\n"))

    if resultat_ok
      @suivi << "= Synchronisation de la collection Narration OK"
    else
      @suivi << "  # Problème avec la synchronisation de la collection Narration"
    end
  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end

  # Synchornisation de la base de données des analyses de films
  # + les fichiers des analyses (tous, c'est-à-dire aussi bien les
  # fichiers d'analyse proprement dits que les fichiers css, les
  # images, etc.)
  #
  # La méthode a été inaugurée car la table `films` peut être modifiée
  # en local comme en distant.
  # LOCAL : C'est principalement les options (qui vont déterminer l'état
  #         de l'analyse, sa visibilité, etc.)
  # DISTANT :   Pour le moment, seul le `sym` du film peut être modifé,
  #             lorsque la fiche filmodico du film est modifiée ou créée.
  #
  def synchronize_analyses
    @suivi << "* Synchronisation des Analyses"

    if param(:cb_synchronize_analyses) == 'on'
      @suivi << "  ** Base de données des analyses"

      # Le sym peut avoir été modifié
      # Il peut s'agir d'un nouveau film
      SuperFile::new('./objet/analyse/lib/module/sync').require
      synan = SynchroAnalyse.instance
      resultat_ok = synan.synchronize
      @suivi << (synan.suivi.collect{|p| "  #{p}"}.join("\n"))
      if resultat_ok
        @suivi << "= Synchronisation des analyses OK"
      else
        @suivi << "  # Problème avec la synchronisation des analyses"
      end
    end

    if param(:cb_sync_analyse_files) == 'on'
      @suivi << "  ** Synchronisation des fichiers d'analyse "
      dsync = data_synchronisation[:analyse_files]
      debug "Fichiers à synchroniser : #{dsync.pretty_inspect}"

      # Fichiers à uploader
      dsync[:to_upload].each do |prel|
        path_loc = "./data/analyse/#{prel}"
        path_dis = "./www/data/analyse/#{prel}"
        cmd = "scp -p #{path_loc} #{serveur_ssh_boa}:#{path_dis}"
        res = `#{cmd} 2>&1`
        if res != ""
          err_mess = "# ERREUR UPLOAD ANALYSE #{prel} : #{res}"
          error err_mess
          debug err_mess
        end
      end

      # Fichiers à détruire
      to_destroy_as_list = dsync[:to_destroy].collect{|p| "'#{p}'"}.join(', ')
      cmd = <<-CODE
errors = Array::new
[#{to_destroy_as_list}].each do |prel|
  begin
    File.unlink File.join('./www/data/analyse', prel)
  rescue Exception => e
    errors << ('- ' + e.message)
  end
end
STDOUT.write Marshal::dump(errors: errors)
      CODE
      debug "COMMANDE DESTRUCTION FILES ANALYSE : #{cmd}"
      # Exécuter la commande SSH pour détruire les fichiers ONLINE
      ret_destroy = `ssh #{serveur_ssh_boa} "ruby -e \\"#{cmd}\\""`
      ret_destroy = Marshal::load(ret_destroy)
      if ret_destroy[:errors].count > 0
        error "# ERREURS EN DÉTRUISANT DES FICHIERS D'ANALYSE : #{ret_destroy[:errors].join('<br>')}"
      end
    end


  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end


  # Synchronisation du Scénodico, sur BOA et sur ICARE
  #
  # Cela consiste à :
  #   - downloader le filmodico du site BOA distant
  #   - uploader le filmodico vers Icare
  def synchronize_filmodico
    @suivi << "* Synchronisation du Filmodico"

    # Les trois paths de la base Filmodico
    local_path  = File.expand_path("./database/data/filmodico.db")
    boite_path  = "./www/database/data/filmodico.db"
    icare_path  = "./www/storage/db/filmodico.db"

    # Rapatrier le fichier boa distant
    cmd = "scp -p #{serveur_ssh_boa}:#{boite_path} #{local_path}"
    res = `#{cmd}`
    @suivi << "\tfilmodico.db - Retour de download Boa distant -> local : #{res.inspect}"
    # Copier le fichier local vers Icare
    cmd = "scp -p #{local_path} #{serveur_ssh_icare}:#{icare_path}"
    res = `#{cmd}`
    @suivi << "\tfilmodico.db - Retour d'upload local -> Icare : #{res.inspect}"

    @suivi << "= Synchronisation du Filmodico OK"
  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end

  # Synchronisation du Scénodico, sur BOA et sur ICARE
  def synchronize_scenodico
    @suivi << "* Synchronisation du Scénodico"

    # Les trois paths de la base Filmodico
    local_path  = File.expand_path("./database/data/scenodico.db")
    boite_path  = "./www/database/data/scenodico.db"
    icare_path  = "./www/storage/db/scenodico.db"

    # Rapatrier le fichier boa distant
    cmd = "scp -p #{serveur_ssh_boa}:#{boite_path} #{local_path}"
    res = `#{cmd}`
    @suivi << "\tscenodico.db - Retour de download Boa distant -> local : #{res.inspect}"
    # Copier le fichier local vers Icare
    cmd = "scp -p #{local_path} #{serveur_ssh_icare}:#{icare_path}"
    res = `#{cmd}`
    @suivi << "\tscenodico.db - Retour d'upload local -> Icare : #{res.inspect}"

    @suivi << "= Synchronisation du Scénodico OK"
  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end

  # Synchronisation des tâches
  def synchronize_taches
    @suivi << "* Synchronisation des tâches"

    Admin::require_module 'taches'
    ::Admin::Taches::synchronize_taches
    @suivi << (::Admin::Taches::suivi.collect{|p| "\t\t#{p}"}.join("\n"))

    @suivi << "= Synchronisation des tâches OK"
  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end

  # Synchronisation de toutes les affiches
  def synchronize_affiches

    return error "Les données de synchronisation sont erronées… Il suffit peut-être de relancer le check." unless data_synchronisation.has_key?(:affiches)

    @suivi << "* Synchronisation des affiches de film"

    [
      ["Icare",   :icare, serveur_ssh_icare,  File.join('.', 'www', 'img', 'affiches')],
      ["B.O.A.",  :boa,   serveur_ssh,        File.join('.', 'www', 'view', 'img', 'affiches')]
    ].each do |lieu, ident, serveur, dis_folder|
      uploads = data_synchronisation[:affiches][ident][:uploads]
      deletes = data_synchronisation[:affiches][ident][:deletes]

      # Uploader les affiches
      # ---------------------
      uploads.each do |affiche_name|
        local_path = File.expand_path(File.join('.', 'view', 'img', 'affiches', affiche_name))
        raise "L'affiche `#{local_path}` devrait exister !" unless File.exist?(local_path)
        distant_path = File.join(dis_folder, affiche_name)
        cmd = "scp -p #{local_path} #{serveur}:#{distant_path}"
        # debug "command upload : #{cmd}"
        res = `#{cmd}`
        @suivi << "Retour de upload affiches #{lieu} : #{res.inspect}"
      end

      # Détruire les affiches
      # ---------------------
      unless deletes.empty?
        res = `ssh #{serveur} "ruby -e \\"#{script_deletions_affiches dis_folder, deletes}\\""`
        @suivi << "Retour de delete affiches #{lieu} : #{res.inspect}"
      end

    end

  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end

  def script_deletions_affiches dis_folder, deletes
    deletes_str = deletes.collect { |aname| "'#{aname}'"}.join(', ')
    <<-CODE
errors = Array::new
[#{deletes_str}].collect do |affiche_name|
  path = File.join('#{dis_folder}', affiche_name)
  if File.exist? path
    File.unlink(path)
  else
    errors << 'Le fichier \'' + path + '\' est introuvable.'
  end
end
mess = if errors.count > 0
  'ERRORS : ' + errors.join(', ')
else
  'OK'
end
STDOUT.write mess
    CODE
  end
end #/Sync
