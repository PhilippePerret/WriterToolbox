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

    synchronize_tweets      if param(:cb_synchronize_permtweets)

    synchronize_narration   if param(:cb_synchronize_narration) || param(:cb_synchro_files_narration)

    synchronize_scenodico   if param(:cb_synchronize_scenodico)

    synchronize_filmodico   if param(:cb_synchronize_filmodico)

    synchronize_analyses    if param(:cb_synchronize_analyses) || param(:cb_sync_analyse_files)


    # Les bases de données qui contiennent plusieurs tables
    # à synchroniser doivent être chargées ici si nécessaire
    Sync::Database.site_cold.upload_if_needed

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
    array_backup << "./database/data/cnarration.db" if param(:cb_synchronize_narration)
    array_backup << "./database/data/scenodico.db"  if param(:cb_synchronize_scenodico)
    array_backup << "./database/data/filmodico.db"  if param(:cb_synchronize_filmodico)
    array_backup << "./database/data/analyse.db"    if param(:cb_synchronize_analyses)

    folder_backup = SuperFile::new('./tmp/backups')
    folder_backup.build unless folder_backup.exist?
    folder_backup_now = folder_backup + "backup-#{Time.now.strftime('%Y%m%d-%H%M')}"
    folder_backup_now.remove if folder_backup_now.exist?
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

  # Synchronisation de la table des citations.
  #
  # Tout ce qu'il y a à faire, c'est récupérer les dates
  # de derniers envois des citations (last_sent) pour les
  # injecter dans la table locale.
  #
  # Noter que cette synchronisation est presque identique
  # à celle des tweets permanents et qu'on pourrait donc
  # être plus DRY en rationalisant les choses.
  #
  def synchronize_citations
    @suivi << "* Synchronisation des citations (last_sent)"

    table_loc = site.dbm_table(:cold, 'citations', online = false)
    table_dis = site.dbm_table(:cold, 'citations', online = true)

    req = { colonnes: [:last_sent] }
    # *** On prend les données de la base distante, à
    # savoir des hashs {:id, :count, :last_sent}
    begin
      table_dis.select(req).each { |h| rs_dis.merge!(h['id'] => h) }
    rescue Exception => e
      debug e
      error "Une erreur est survenue en récupérant les informations des citations distantes. Je dois renoncer."
      return false
    end

    # *** On prend les données de la base locale
    begin
      table_loc.select(req).each { |h| rs_loc.merge!(h['id'] => h) }
    rescue Exception => e
      debug e
      error "Une erreur est survenur en récupérant les informations des citations locales. Je dois renoncer."
      return
    end

    # *** On calcule la différence
    rs_diff = []
    rs_dis.each do |tid, tdata_online|
      if rs_loc[tid] != tdata_online
        rs_diff << tdata_online
      end
    end

    # *** On actualise les données à actualiser
    unless rs_diff.empty?
      begin
        rs_dis.each do |cdata|
          table_loc.update( cdata[:id], cdata )
        end
      rescue Exception => e
        debug e
        error "Impossible d'actualiser les données tweets permanents. Je dois renoncer…"
        return
      end
    end

    @suivi << "= Synchronisation des citations OK"
  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end


  # Synchronisation de la table des tweets permanents.
  #
  # Cette opération est faite à chaque synchronisation, elle
  # consiste simplement à prendre les :count et :last_sent de
  # la base online pour les reporter sur la base locale.
  #
  # Rappel : La base locale permet d'ajouter des tweets
  # permanents, mais c'est en online que les tweets sont
  # envoyés (lors du cron horaire) et c'est donc en online que
  # les valeurs :count et :last_sent des tweets sont incrémentés.
  def synchronize_tweets
    @suivi << "* Synchronisation des tweets permanents"


    # *** On prend les données de la base distante, à
    # savoir des hashs {:id, :count, :last_sent}
    table_tweets_dis = site.dbm_table(:cold, 'permanent_tweets', online = true)
    begin
      rs_dis = {}
      table_tweets_dis.select(colonnes: [:count, :last_sent]).each do |htweet|
        rs_dis.merge! htweet[:id] => htweet
      end
    rescue Exception => e
      debug e
      error "Une erreur est survenue en récupérant les informations des tweets permanents distants. Je dois renoncer."
      return false
    end

    # *** On prend les données de la base locale
    #
    # Ici, il faut prendre toutes les données car des nouveaux tweets
    # seront peut-être à ajouter.
    table_tweets_loc = site.dbm_table(:cold, 'permanent_tweets', online = false)
    begin
      rs_loc = {}
      table_tweets_loc.select(colonnes: nil).each do |htweet|
        rs_loc.merge! htweet[:id] => htweet
      end
    rescue Exception => e
      debug e
      error "Une erreur est survenur en récupérant les informations des tweets permanents locaux. Je dois renoncer."
      return
    end

    # *** On calcule la différence au niveau des
    # count et des last_sent
    rs_diff = []
    liste_ids_traited = []
    rs_dis.each do |tid, tdata_dis|
      liste_ids_traited << tid
      tdata_loc = rs_loc[tid]
      if (tdata_loc[:count] != tdata_dis[:count]) || (tdata_loc[:last_sent] != tdata_dis[:last_sent])
        rs_diff << tdata_dis
      end
    end

    # Voir les tweets en offline qu'il faut
    # ajouter online
    rs_diff_loc = []
    rs_loc.each do |tid, tdata_loc|
      next if liste_ids_traited.include?( tid )
      rs_diff_loc << tdata_loc
    end

    # Il faut actualiser la table si
    # 1/ les nombres de tweets sont différents ou
    # 2/ des différences ont été relevées.
    return if rs_diff.empty? && rs_dis.count == rs_loc.count

    # *** On actualise les données à actualiser
    begin
      rs_diff_loc.each do |dtweet|
        table_tweets_dis.insert(dtweet)
      end
    rescue Exception => e
      debug e
      error "Impossible d'actualiser les données tweet nouvelles."
      return
    end

    # Actualisation des données locales, modifiées en
    # online
    begin
      rs_diff.each do |tid, tdata|
        table_tweets_loc.update(tid, {count: tdata[:count], last_sent: tdata[:last_sent]})
      end
    rescue Exception => e
      debug e
      error "Impossible d'actualiser les données tweets permanents. Je dois renoncer…"
      return
    end

    @suivi << "= Synchronisation des tweets permanents OK"
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
        folder_dis = File.dirname(path_dis)
        # On s'assure toujours que le dossier existe
        cmd = "ssh #{serveur_ssh_boa} \"mkdir -p #{folder_dis}\" && scp -p #{path_loc} #{serveur_ssh_boa}:#{path_dis}"
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

    error "Il ne faut plus utiliser sqlite3 pour le filmodico + ne plus l'utiliser sur Icare."
    return

    @suivi << "= Synchronisation du Filmodico OK"
  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    @errors << e.message
  end

  # Synchronisation du Scénodico, sur BOA et sur ICARE
  def synchronize_scenodico
    @suivi << "* Synchronisation du Scénodico"

    error "Il ne faut plus utiliser sqlite3 pour le scenodico + ne plus l'utiliser sur Icare."
    return

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
