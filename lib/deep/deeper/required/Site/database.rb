# encoding: UTF-8
class SiteHtml

  # @usage:  site.db.<méthode>
  def db
    @db ||= DB.instance
  end

  class DB
    include Singleton

    # @usage  site.db.table('<base>', '<table>')
    def table dbname, tblname
      database_of(dbname).table(tblname)
    end

    # Méthode principale à appeler quand on veut récupérer une table en
    # la créant si elle n'existe pas.
    # RETURN {BdD::Table} La table, si elle a pu être créée
    # @Usage :
    #     def ma_table
    #       @ma_table ||= site.db.create_table_if_needed('basename', 'tablename')
    #     end
    #
    def create_table_if_needed db_name, table_name
      creation_required = false
      creation_required = false == database_exists?( db_name )
      creation_required ||= (false == database_of( db_name ).table_exist?( table_name ))
      create_table(db_name, table_name) if creation_required
      database_of(db_name).table(table_name)
    end

    # = main =
    #
    # Méthode principale pour créer une table
    #
    def create_table db_name, table_name
      # Il faut charger la définition de la table
      # C'est un module qui contient simplement la méthode
      # qui définit la table
      db    = database_of(db_name)
      schem = schema(db_name, table_name)
      build_table( db, table_name, schem )
    end

    # Méthode qui construit vraiment la table
    # Note : Elle a été séparée de `create_table` ci-dessous pour
    # pouvoir être appelée pour construire des tables particulières
    # qui ne respectent pas les conventions générales (c'est parfois
    # nécessaire)
    # Note : La table n'est créée que si elle n'existe pas.
    def build_table database, table_name, schem
      database = BdD::new(database.to_s) unless database.instance_of?(BdD)
      table = database.table( table_name )
      unless table.exist?
        table.define schem
        table.create
      end
    end

    def database_exists? db_name
      (path_database_of db_name).exist?
    end

    def database_of db_name
      BdD::new((path_database_of db_name).to_s)
    end

    def path_database_of db_name
      site.folder_db + "#{db_name}.db"
    end

    # {Hash} Retourne le schéma de la table de nom `table_name` dans
    # la base de nom `db_name`. Cf. RefBook utilisation
    def schema db_name, table_name
      path = site.folder_tables_definition + "db_#{db_name}/table_#{table_name}.rb"
      raise "Impossible de trouver la définition de la table : `#{path.to_s}`…" unless path.exist?
      path.require
      self.send("schema_table_#{db_name}_#{table_name}")
    end

  end

end
