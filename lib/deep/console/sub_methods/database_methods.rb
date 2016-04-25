# encoding: UTF-8
=begin

  show_table <{BdD::Table} table>

  La méthode `show_table` se trouve dans le fichier
    ./lib/deep/deeper/module/console/table.rb

=end
raise_unless_admin

require 'pstore' # pour les backups provisoires

class SiteHtml
class Admin
class Console

  # Retourne un array contenant la base de données ({BdD}) et la table
  # ({BdD::Table}) pour un +last_word+ qui ressemble à "path/to/db.latable"
  # Produit les erreurs si problème et retourne nil
  def db_path_and_table_from_last_word last_word
    path, table = last_word.split('.')
    raise "Il faut définir le nom de la table dans la requête." if table.nil?
    full_path = SuperFile::new("./database/data/#{path}.db")
    raise "La base de données `#{full_path}` n'existe pas…" unless full_path.exist?
    bdd = BdD::new(full_path.to_s)
    tbl = ( bdd.table table )
    raise "La table `#{table}` n'existe pas dans la base de données spécifiée (dont l'existence a été vérifiée)" unless bdd.table(table).exist?
    return [bdd, tbl]
  rescue Exception => e
    sub_log "`#{last_word}` est invalide.\n" +
      "Expected : path/to/db/depuis/database/data/sans/db DOT nom_table\n"+
      "Example  : `show table forum.posts`\n" +
      "Pour     : la table `posts` dans la db `./database/data/forum.db`."

    ["# ERROR: #{e.message}", nil]
  end

  # Détruit définitivement la table
  # Par mesure de prudence, une copie est fait de la base originale,
  # mise dans le dossier temporaire
  def destroy_table_of_database last_word
    sub_log "Destruction de la table : #{last_word}"
    bdd, tbl = db_path_and_table_from_last_word last_word
    return bdd if tbl.nil?
    dest_path = (site.folder_tmp + "#{bdd.name}-prov.db")
    dest_path.remove if dest_path.exist?
    FileUtils::cp bdd.path, dest_path
    tbl.remove
    if tbl.exist?
      "ERROR : Table non détruite"
    else
      sub_log "<br>Copie de : `#{bdd.path}`"
      sub_log "<br>Dans : `#{dest_path}`"
      "Table détruite avec succès"
    end
  end

  # Vide (sans la détruire )
  def vide_table_of_database last_word
    sub_log "Vidage (sans destruction) de la table : #{last_word}"
    bdd, tbl = db_path_and_table_from_last_word last_word
    return bdd if tbl.nil?
    tbl.pour_away
    ""
  end

  def affiche_table_of_database last_word
    sub_log "Affichage de la table : #{last_word}"
    bdd, tbl = db_path_and_table_from_last_word last_word
    return bdd if tbl.nil?
    show_table tbl
  end





  # Produit un backup des données de la table +table_name+
  # dans la base +current_db_name+ en traitant la table
  # dans tous les gels de données.
  #
  # +current_db_name+ {String}
  #     Path relatif à la base de données, à partir du dossier
  #     ./database/data
  # +table_name+ {String}
  #     Nom de la table, qui doit exister.
  #
  def backup_data_from_all current_db_name, table_name
    # La base de données doit exister
    main_db_path = site.folder_db + current_db_name.to_s
    raise "La base de données #{main_db_path} est introuvable…" unless main_db_path.exist?

    # La base de données courante
    all_dbs = Dir["./data/gel/**/#{current_db_name}"]
    # Toutes les bases identiques des gels
    all_dbs << main_db_path
    # On les traite toutes
    nombre_backups = 0
    nombre_erreurs = 0
    errors = Array::new
    all_dbs.each do |dbpath|
      errs = backup_data_of(dbpath, table_name, {quiet: true})
      if errs.nil?
        nombre_backups += 1
      else
        nombre_erreurs += 1
        errors += errs
      end
    end
    if nombre_backups > 0
      flash "#{nombre_backups} backups exécutés avec succès"
    else
      error "AUCUN BACKUP N'A PU ÊTRE EXÉCUTÉ."
    end
    if nombre_erreurs > 0
      error "#{nombre_erreurs} erreurs (peut-être non fatales) se sont produites, consulter le debug."
      debug "\n\nERREUR AU COURS DE backup_data_from_all :" +
      errors.join("\n") + "\n\n"
    end
  end

  # ---------------------------------------------------------------------

  # {SuperFile} Pstore qui va contenir le backup des
  # données des tables à modifier.
  def pstore_path_for dbpath, table_name
    SuperFile::new("#{dbpath.to_s}.#{table_name}.pstore")
  end
  # Ces deux méthodes génériques, 'backup_data_of' et
  # 'retrieve_data_from' visent à permettre de modifier les
  # tables sans perdre toutes les données (lorsque ce n'est pas
  # simplement l'ajout d'une colonne)
  # Le principe est de prendre les données pour faire un backup
  # (la base est copiée ou alors on met tout dans un pstore)
  # puis ensuite, pour le retrieve_data_from, on donne un schéma
  # qui permet de transformer les données. Par exemple en indiquant
  # la nouvelle valeur qui doit être ajoutée.
  #
  # +options+ {Hash}
  #   :quiet      Si true, les messages d'erreur ne sont pas raisés
  #               mais retournés.
  #
  def backup_data_of path, table_name, options = nil
    options ||= Hash::new
    quiet = !!options[:quiet]
    @errors = Array::new
    unless File.exist?(path)
      err_mess = "La base de données `#{path}` n'existe pas. Impossible de faire le backup des données."
      raise err_mess unless quiet
      @errors << err_mess
      return @errors
    end
    database  = BdD::new(path.to_s)
    table     = database.table( table_name )
    unless table.exist?
      err_mess = "La table `#{table_name}` n'existe pas dans la base de donnée `#{path}`. Impossible de faire le backup des données."
      raise err_mess unless quiet
      @errors << err_mess
      return @errors
    end
    pstore_path = pstore_path_for(path, table_name)
    pstore_path.remove if pstore_path.exist?
    PStore::new(pstore_path.to_s).transaction do |ps|
      BdD::new(path.to_s).table(table_name).select.each do |id, data|
        ps[id] = data
      end
    end
  rescue Exception => e
    if quiet
      return [e.message]
    else
      error "#{e.message} (mais je poursuis le travail)."
    end
  else
    return nil # pas d'erreurs
  end



  # ---------------------------------------------------------------------

  # Récupération des données de la table +table_name+ de la
  # base +current_db_name+ en appliquant sur les données la
  # procédure +proc_modif+ si elle existe.
  #
  # Les données à récupérer DOIVENT IMPÉRATIVEMENT avoir été
  # backupées avec la procédure `backup_data_from_all` un peu
  # plus bas dans le programme.
  #
  # L'opération s'appelle `from_all` car elle est exécutée sur
  # TOUS LES GELS qui ont été produits, if any.
  #
  # +current_db_name+ {String}
  #     Path relatif de la base de données à partir du
  #     dossier ./database/data/
  # +table_name+ {String}
  #     Le nom de la table dans la base de données
  # +proc_modif+ {Proc}
  #     Procédure de transformation des données, en fonction de
  #     la transformation de la table.
  #     Cf. la méthode `retrieve_data_from` pour
  def retrieve_data_from_all current_db_name, table_name, proc_modif = nil
    main_db_path = site.folder_db+current_db_name.to_s
    raise "La base de données #{main_db_path} est introuvable." unless main_db_path.exist?
    # Toutes les bases identiques des gels
    all_dbs = Dir["./data/gel/**/#{current_db_name}"]
    # La base de données courante
    all_dbs << main_db_path

    # Soit la procédure de transformation est envoyée en
    # 3e paramètre soit elle est définie dans la méthode
    # principale. Tout dépend si l'on utilise une commande
    # dédiée à une table propre ou si on utilise la commande
    # console générale `retreive_data base.table`
    proc_modif ||= db_procedure_transformation_data

    # On les traite toutes
    nombre_succes = 0
    nombre_errors = 0
    all_dbs.each do |dbpath|

      debug "Traitement de #{dbpath}"

      if retrieve_data_from(dbpath, table_name, proc_modif)
        nombre_succes += 1
      else
        nombre_errors += 1
      end
    end
    if nombre_succes > 0
      flash "#{nombre_succes} tables ont pu être traitées avec succès."
    else
      error "AUCUNE TABLE N'A PU ÊTRE TRAITÉES…"
    end
    if nombre_errors > 0
      error "Nombre d'erreurs produites : #{nombre_errors} (non fatales)"
    else
      flash "Aucune erreur ne s'est produite."
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
  def retrieve_data_from path, table_name, schema

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
    raise "Le pstore `#{pstore_path}` n'existe pas : impossible de récupérer les données" unless pstore_path.exist?
    PStore::new(pstore_path.to_s).transaction do |ps|
      ps.roots.each do |id|
        hdata = ps[id]
        # Ici, le schéma permet de modifier les données avant de les
        # insérer dans la nouvelle table. Sauf s'il est nil.
        hdata = schema.call(hdata) unless schema.nil?
        # Si data est nil, c'est qu'il faut supprimer la donnée
        next if hdata.nil?
        # On peut enfin insérer la donnée, en gardant absolument
        # le même identifiant.
        table.set(id, hdata )
      end
    end


  rescue Exception => e
    error "#{e.message} (mais je poursuis le travail)."
  else
    # Puisqu'on est ici, c'est que toutes les données ont pu
    # être récupérées. On détruit donc le pstore.
    pstore_path.remove
    # Et on retourne true pour indiquer que tout s'est bien passé
    true
  end

end #/Console
end #/Admin
end #/SiteHtml

=begin
=end
