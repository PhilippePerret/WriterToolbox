# encoding: UTF-8
=begin
Class Bdd (instance)
--------------------

Une instance BdD est une base de données, donc un fichier SQLite3
=end
class BdD

  # {String} Path au fichier de la base
  attr_reader :path

  # {String} Le code actuellement exécuté
  attr_reader :current_code

  # {Array of Error} Les erreurs rencontrées
  # Utiliser la méthode `add_error' pour en ajouter une
  attr_reader :errors

  ##
  # Instanciation d'une base de données
  # ----------------------------------
  # Si le fichier de la base n'existe pas encore, c'est une création
  # de la base et on doit produire son fichier avec une table qui
  # va contenir les noms des colonnes de chaque table créée.
  #
  # +path+ {String} Chemin d'accès au fichier de la base
  #
  def initialize path
    @path = path
    check_data_or_raise
    on_create unless File.exist? path
  end

  ##
  # Retourne l'instance BdD::Table de la table +table_name+ de
  # cette base de données
  # Alias : def get_table <table_name>
  def table table_name
    @tables ||= Hash::new
    @tables[table_name] ||= BdD::Table::new( self, table_name )
  end
  alias :get_table :table

  ##
  # Exécution d'un code dans la BdD
  # +code+ {String} Le code SQL à exécuter
  def execute code, return_if_success = nil
    @current_code = code
    begin
      result = database.execute code
    rescue Exception => e
      messerr = "ERREUR SQL EN EXÉCUTANT : #{code.inspect}"
      debug messerr if respond_to?(:debug)
      cron.log "### #{messerr}" if respond_to?(:cron)
      return add_error( e )
    else
      return return_if_success || result
    end
  end

  # => Instance SQLite3::Database de la base de données
  def database  ; @database ||= ( ::SQLite3::Database::new path ) end

  # Retourne le nom de la base de donnée (= affixe du fichier)
  def name
    @name ||= File.basename(path, File.extname(path) )
  end

  ##
  # Création de la BDD
  # Appelé lors de la toute première instanciation de la base, lorsque
  # lorsqu'elle n'existe pas encore.
  # On va :
  #   - créer la table __column_names__ qui va conserver le nom
  #     des colonnes des tables.
  #
  def on_create
    create_table_column_names
  end

  ##
  #Retourne la liste des noms de table
  def table_names
    @table_names ||= BdD::Table::table_names(self)
  end

  ##
  # Retourne TRUE si la table +table_name+ existe dans la
  # base de données
  def table_exist? table_name
    BdD::Table::exist? self, table_name
  end
  alias :has_table? :table_exist?

  ##
  # Définit dans la table `_columns_names_' la liste des colonnes
  # de la table +table_name+
  # Noter qu'il peut s'agir d'une redéfinition des colonnes déjà dans
  # la base, en cas de changement de schéma de table.
  def add_column_names_of_table table_name, arr_column_names
    # debug "-> add_column_names_of_table(#{table_name})"
    has_row = table_column_names.has_row_with?("table_name = '#{table_name}'")
    # debug "Has row : #{has_row.inspect}"
    column_names = arr_column_names.join(',')
    code_sql = unless has_row
      # debug "-> insertion de la liste des colonnes de #{table_name}"
      "INSERT INTO __column_names__ (table_name, columns) VALUES ('#{table_name}', '#{column_names}');"
    else
      # debug "-> actualisation de la liste des colonnes de #{table_name}"
      "UPDATE __column_names__ SET columns = '#{column_names}' WHERE table_name = '#{table_name}';"
    end
    res = table_column_names.execute code_sql
    # debug "Retour : #{res.inspect}"
    # debug "<- add_column_names_of_table(#{table_name})"
  end

  ##
  # {Array} Retourne les noms de colonnes des la table +table_name+
  def column_names_of_table table_name
    res = table_column_names.execute("SELECT * FROM __column_names__ WHERE table_name = '#{table_name}'")
    return res[1].split(',')
  end

  ##
  # La table qui conserve les noms de colonnes de chaque table
  def table_column_names
    @table_column_names ||= get_table( '__column_names__' )
  end

  private

    def create_table_column_names
      # debug "-> create_table_column_names"
      code_sql = "CREATE TABLE __column_names__ "
      code_sql << "(table_name VARCHAR(255) PRIMARY KEY NOT NULL, columns BLOB NOT NULL);"
      # Création de la table
      res = database.execute code_sql
      # debug "Retour création table colonnes : #{res.inspect}"
      # On insert la table elle même
      res = database.execute "INSERT INTO __column_names__ (table_name, columns) VALUES ('__column_names__', 'table_name,columns')"
      # debug "Retour insertion colonnes de table colonnes : #{res.inspect}"
      # debug "<- create_table_column_names"
    end


    ##
    # Ajoute une erreur
    # +err+ {Error} L'instance de l'erreur
    def add_error err
      @errors ||= Array::new
      @errors << err
      debug err
      return false
    end

    ##
    # Procédure de vérification des données envoyées à
    # l'instanciation de la base
    def check_data_or_raise
      raise BdDError, :instance_bad_path unless path.class == String
    rescue BdDError => e
      raise ArgumentError, ::BdD::ERRORS[e.message.to_sym]
    rescue Exception => e
      debug e
      error e.message
    end

end
