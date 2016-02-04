# encoding: UTF-8
raise_unless_admin

require 'pstore'

class SiteHtml
class Admin
class Console

  # ---------------------------------------------------------------------
  # Méthodes de récupération des données
  # (qui ont été backupées dans des PStores)
  def retreive_data_pages_cours
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retreive_data_from_all( 'unan_cold.db', 'page_cours', proc_modif )
  end

  def retreive_data_exemples
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    # La table courante
    retreive_data_from_all('unan_cold.db', 'exemples', proc_modif)
  end
  # Noter qu'il ne suffit pas de traiter les tables courantes mais
  # également celles de tous les gels…
  def retreive_data_programs
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    # La table courante
    retreive_data_from_all('unan_hot.db', 'programs', proc_modif)
  end
  def retreive_data_absolute_works
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      # debug "data work : #{data.inspect}"
      data = data_init.dup
      data # doit être retourné (ou nil)
    end
    retreive_data_from_all('unan_cold.db', 'absolute_works', proc_modif)
  end
  def retreive_data_absolute_pdays
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retreive_data_from_all('unan_cold.db', 'absolute_pdays', proc_modif)
  end
  def retreive_data_projets
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retreive_data_from_all('unan_hot.db', 'projets', proc_modif)
  end
  def retreive_data_questions
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retreive_data_from_all('unan_cold.db', 'questions', proc_modif)

  end
  def retreive_data_quiz
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retreive_data_from_all('unan_cold.db', 'quiz', proc_modif)
  end


  #
  # /Fin des méthodes de récupération des data
  # ---------------------------------------------------------------------


  # ---------------------------------------------------------------------

  # On récupère les données pour la table +table_name+ courante dans
  # la base {String} current_db_name ainsi que pour TOUTES les tables
  # identiques des gels
  def retreive_data_from_all current_db_name, table_name, proc_modif
    # La base de données courante
    all_dbs = Dir["./data/gel/**/#{current_db_name}"]
    # Toutes les bases identiques des gels
    all_dbs << site.folder_db+current_db_name.to_s
    # On les traite toutes
    all_dbs.each do |dbpath|
      retreive_data_from(dbpath, table_name, proc_modif)
    end
  end

  # Pour la table courante et TOUTES LES TABLES dans tous les
  # gels
  def backup_data_from_all current_db_name, table_name
    # La base de données courante
    all_dbs = Dir["./data/gel/**/#{current_db_name}"]
    # Toutes les bases identiques des gels
    all_dbs << site.folder_db + current_db_name.to_s
    # On les traite toutes
    all_dbs.each do |dbpath|
      backup_data_of(dbpath, table_name)
    end
  end

  # ---------------------------------------------------------------------

  def init_unan
    site.require_objet 'unan'
  end

  # {SuperFile} Pstore qui va contenir le backup des
  # données des tables à modifier.
  def pstore_path_for db_path, table_name
    SuperFile::new("#{db_path.to_s}.#{table_name}.pstore")
  end
  # Ces deux méthodes génériques, 'backup_data_of' et
  # 'retreive_data_from' visent à permettre de modifier les
  # tables sans perdre toutes les données (lorsque ce n'est pas
  # simplement l'ajout d'une colonne)
  # Le principe est de prendre les données pour faire un backup
  # (la base est copiée ou alors on met tout dans un pstore)
  # puis ensuite, pour le retreive_data_from, on donne un schéma
  # qui permet de transformer les données. Par exemple en indiquant
  # la nouvelle valeur qui doit être ajoutée.
  def backup_data_of path, table_name
    raise "La base de données `#{path}` n'existe pas. Impossible de faire le backup des données." unless File.exist?(path)
    database  = BdD::new(path.to_s)
    table     = database.table( table_name )
    raise "La table `#{table_name}` n'existe pas dans la base de donnée `#{path}`. Impossible de faire le backup des données." unless table.exist?
    pstore_path = pstore_path_for(path, table_name)
    pstore_path.remove if pstore_path.exist?
    PStore::new(pstore_path.to_s).transaction do |ps|
      BdD::new(path.to_s).table(table_name).select.each do |id, data|
        ps[id] = data
      end
    end
  end
  # +path+ le path de la base de données courante
  # +table_name+  le nom de la table
  # +schema+      Le schéma de modification des données par rapport au
  #               backup. C'est une procédure dont l'argument est le
  #               Hash des données anciennes (actuelles)
  #               Donc on définit ce schéma par :
  #               schema = Proc::new do |data|
  #                 ... traitement de data...
  #                 ... propre à la nouvelle table ...
  #                 data # il faut absolument terminer par data à retourner
  #               end
  def retreive_data_from path, table_name, schema

    # Pour simplifier, on détruit et on reconstruit la table
    # concernée ici seulement

    # Destruction de la table courante, si elle existe
    db = SQLite3::Database::new(path)
    db.execute("DROP TABLE IF EXISTS #{table_name};")
    db_name = File.basename(path)
    db_affixe = File.basename(path, File.extname(path))

    # On récupère le schéma de la table, qui va nous permettre
    # de la reconstruire
    table_schema_path = "./database/tables_definition/db_#{db_affixe}/table_#{table_name}.rb"
    table_schema_method = "schema_table_#{db_affixe}_#{table_name}".to_sym
    require table_schema_path
    table_schema = send(table_schema_method)

    # Données utiles pour la suite
    database  = BdD::new(path.to_s)
    table     = database.table( table_name )

    # On peut reconstruire la table d'après son schéma
    table.define table_schema
    table.create

    # À présent, on peut récupérer les données et les
    # remettre dans la nouvelle table en respectant le nouveau
    # schéma défini
    pstore_path = pstore_path_for(path, table_name)
    raise "Le pstore `#{pstore_path}` est malheureusement introuvable : impossible de récupérer les données" unless pstore_path.exist?
    PStore::new(pstore_path.to_s).transaction do |ps|
      ps.roots.each do |id|
        data = ps[id]
        # Ici, le schéma permet de modifier les données avant de les
        # insérer dans la nouvelle table
        data = schema.call(data)
        # Si data est nil, c'est qu'il faut supprimer la donnée
        next if data.nil?
        # On peut enfin insérer la donnée, en gardant absolument
        # le même identifiant.
        table.set(id, data )
      end
    end
  end


  def backup_data_exemples
    backup_data_from_all('unan_cold.db', 'exemples')
  end
  def backup_data_questions
    backup_data_from_all('unan_cold.db', 'questions')
  end
  def backup_data_quiz
    backup_data_from_all('unan_cold.db', 'quiz')
  end
  def backup_data_absolute_pdays
    backup_data_from_all('unan_cold.db', 'absolute_pdays')
  end
  def backup_data_pages_cours
    backup_data_from_all('unan_cold.db', 'pages_cours')
  end
  def backup_data_programs
    backup_data_from_all('unan_hot.db', 'programs')
  end
  def backup_data_projets
    backup_data_from_all('unan_hot.db', 'projets')
  end
  def backup_data_absolute_works
    backup_data_from_all('unan_cold.db', 'absolute_works')
  end

  def destruction_impossible
    @destruction_impossible ||= "Impossible de détruire la table des %{choses} en ONLINE (trop dangereux)."
  end
  def detruire_table_exemples
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'exemples';")
      "Table des exemples détruite avec succès."
    else
      destruction_impossible % {choses: "exemples"}
    end
  end
  def detruire_table_questions
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'questions';")
      "Table des questions détruite avec succès."
    else
      destruction_impossible % {choses: "questions"}
    end
  end
  def detruire_table_quiz
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'quiz';")
      "Table des quiz détruite avec succès."
    else
      destruction_impossible % {choses: "quiz"}
    end
  end
  def detruire_table_programs
    if OFFLINE
      init_unan
      Unan::database_hot.execute("DROP TABLE IF EXISTS 'programs';")
      "Table des programmes détruite avec succès."
    else
      destruction_impossible % {choses: "programmes"}
    end
  end

  def detruire_table_projets
    if OFFLINE
      init_unan
      Unan::database_hot.execute("DROP TABLE IF EXISTS 'projets';")
      "Table des projets détruite avec succès."
    else
      destruction_impossible % {choses: "projets"}
    end
  end

  def detruire_table_pages_cours
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'pages_cours';")
      "Table des pages de cours détruite avec succès."
    else
      destruction_impossible % {choses: "pages de cours"}
    end
  end

  def affiche_table_exemples
    init_unan
    show_table Unan::table_exemples
  end
  def affiche_table_questions
    init_unan
    show_table Unan::table_questions
  end
  def affiche_table_quiz
    init_unan
    show_table Unan::table_quiz
  end
  def affiche_table_programs
    init_unan
    show_table Unan::table_programs
  end

  def affiche_table_projets
    init_unan
    show_table Unan::table_projets
  end

  def afficher_table_pages_cours
    init_unan
    show_table Unan::Program::PageCours::table_pages_cours
  end

  def afficher_table_absolute_pdays
    init_unan
    show_table Unan::table_absolute_pdays
  end
  def detruire_table_absolute_pdays
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'absolute_pdays';")
      "Tables des données jours-programme absolus détruite à jamais."
    else
      "Impossible de détruire la table des données absolues\n# des jours-programme ONLINE"
    end
  end


  def afficher_table_absolute_works
    init_unan
    show_table Unan::table_absolute_works
  end

  def detruire_table_absolute_works
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'absolute_works';")
      "Tables des données travaux absolus détruite à jamais."
    else
      "Impossible de détruire la table des données absolues\n# des travaux ONLINE"
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
