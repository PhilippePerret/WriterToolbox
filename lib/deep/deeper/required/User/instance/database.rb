# encoding: UTF-8
=begin

Extensions User instance pour les bases de données

=end
class User

  # Table COMMUNE de tous les users
  def table_users
    @table_users ||= self.class::table_users
  end
  alias :table :table_users

  # Table PERSONNELLE contenant les variables
  # Noter que c'est une méthode d'instance
  # Cf. le fichier `inst_variables.rb`
  def table_variables
    @table_variables ||= create_table_unless_exists('variables')
  end

  # Base de données propre à l'user
  # Attention ! Il ne s'agit pas de la table commune qui contient tous
  # les users, mais la database personnelle qui contient par exemple la
  # table `variables` avec les préférences et autres données variables
  def database
    @database ||= BdD::new(database_sfile.to_s)
  end

  def database_sfile
    @database_sfile ||= folder + "data-#{id}.db"
  end


  # Crée la table +table_name+ (dans la base de données personnelles)
  # si elle n'existe pas.
  # Cette méthode retourne la table et doit donc être utilisée pour
  # récupérer des tables en checkant leur existence.
  def create_table_unless_exists table_name
    tbl = database.table(table_name)
    create_table(tbl) unless tbl.exist?
    return tbl
  end

  # +itable+ Instance {BdD::Table} de la table personnelle à créer
  # Note : Cette table est créée dans la base de données personnelle
  # de l'auteur, comme la table `variables` par exemple
  def create_table itable
    table_name = itable.name
    schema_path = site.folder_tables_definition + "user/table_#{table_name}.rb"
    schema_path.require # charge le fichier de la définition de la table
    schema_method = "schema_table_user_#{table_name}"
    table_schema = send( schema_method.to_sym )
    site.db.build_table(self.database, table_name, table_schema)
    # Barrière en cas de problème
    raise "La table `#{table_name}` n'a pas pu être construite…" unless self.database.table(table_name).exist?
  end

end #/User
