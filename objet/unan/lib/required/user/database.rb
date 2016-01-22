# encoding: UTF-8
=begin
Extensions de User pour les bases de données propres à 1an 1script
=end
class User

  #
  # ---------------------------------------------------------------------
  # TABLES
  #
  # Note : On appelle toujours ces méthodes en premier, car elles
  # permettent de construire les tables si elles n'existent pas
  # encore.
  #
  # Note : La table `variables` est une table de RestSite, pas du
  # programme UN AN UN SCRIPT. On peut donc la trouver dans les
  # librairies de RestSite, pas ici.
  # ---------------------------------------------------------------------
  #

  # Tables des jours-programmes de l'user
  # Noter que c'est une méthode d'instance
  def table_pdays
    @table_pdays ||= get_table('pdays')
  end

  # Table des travaux accomplis ou en cours de l'user
  # Noter que c'est une méthode d'instance
  def table_works
    @table_works ||= get_table('works')
  end

  # La base de données personnelle du programme de l'user,
  # dépendant de l'id de l'user et de l'id du programme.
  # Noter qu'on utilise `program_id` ici (plutôt que `program.id`)
  # car le programme vient d'être défini et on connaitre @program_id
  def program_database
    @program_database ||= BdD::new(program_database_path.to_s)
  end
  # La base de données contenant toutes les données pour le programme
  # de l'utilisateur (sa database personnelle)
  def program_database_path
    @program_database_path ||= begin
      folder_data + "programme#{program.id}.db"
    end
  end

  # Récupérer n'importe quelle table de la base de données personnelle
  # du programme de l'user et la construire si nécessaire.
  def get_table table_name
    unless program_database_path.exist? && program_database.table(table_name).exist?
      create_tables_1a1s
    end
    unless program_database_path.exist? && program_database.table(table_name).exist?
      raise "LA TABLE '#{table_name}' N'EXISTE TOUJOURS PAS ALORS QU'ELLE AURAIT DÛ ÊTRE CONSTRUITE."
    end
    program_database.table(table_name)
  end

  # On construit toutes les tables qui se trouvent dans le dossier
  # `./database/tables_definitions/unan_user/`
  # Noter que la table n'est créée que si elle n'existe pas, donc
  # on peut en ajouter d'autres, pourvu que cette méthode soit
  # appelée pour la créer.
  def create_tables_1a1s
    # debug "-> create_tables_1a1s"
    # debug "Dossier de définition de table : #{folder_tables_definitions.to_s}"
    Dir["#{folder_tables_definitions.to_s}/*.rb"].each do |schema_path|
      table_name = File.basename(schema_path)[6..-4]
      # debug "Nom de la table : '#{table_name}'"
      require schema_path
      schema_method = "schema_table_user_#{table_name}"
      table_schema = send( schema_method.to_sym )
      # debug "Schéma table #{table_name} : #{table_schema.pretty_inspect}"
      site.db.build_table(program_database, table_name, table_schema)
      # Barrière en cas de problème
      raise "La table `#{table_name}` n'a pas pu être construite…" unless get_table(table_name).exist?
      # debug "== Table `#{table_name}` créée avec succès"
    end
  end

  # {SuperFile}
  def folder_tables_definitions
    @folder_tables_definitions ||= site.folder_tables_definition + "user"
  end

end
