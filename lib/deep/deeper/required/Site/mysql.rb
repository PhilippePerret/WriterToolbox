# encoding: UTF-8
require 'mysql2'

class SiteHtml

  # Retourne l'instance SiteHtml::DBM_TABLE de la table MySQL
  def dbm_table db_name, table_name
    DBM_TABLE.get(db_name.to_sym, table_name)
  end

class DBM_TABLE # DBM_TABLE pour DataBase Mysql

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self

    attr_reader :tables

    # Retourne la table (instance {SiteHtml::DBM_TABLE}) de nom
    # +tablename+ dans la base de type +db_type+ qui peut
    # être soit :hot soit :cold.
    def get db_type, tablename
      @tables ||= {}
      @tables["#{db_type}.#{tablename}"] ||= begin
        new(db_type, tablename).create_if_needed
      end
    end

    # Ajoute une table à la liste des tables, pour ne pas
    # avoir à les retester tout le temps. Utile si on ne
    # passe pas par `get` pour récupérer une table.
    def add table
      @tables ||= {}
      @tables["#{table.type}.#{table.name}"] = table
    end

    # Les données pour se connecter à la base mySql
    # soit en local soit en distant.
    def client_data
      @client_data ||= begin
        require './data/secret/mysql'
        OFFLINE ? DATA_MYSQL[:offline] : DATA_MYSQL[:online]
      end
    end

    # Le préfixe du nom (de la base de données) en fonction
    # du fait qu'on est online ou offline
    #
    # Normalement, maintenant, on peut utiliser les deux en
    # online comme en offline.
    #
    def prefix_name
      @prefix_name ||= begin
        # (ONLINE ? 'boite-a-outils' : 'boite_outils_auteur') + '_'
        'boite-a-outils_'
      end
    end

    # {SuperFile} Dossier contenant les schémas des
    # tables des bases de données.
    # Elles sont réparties en deux dossier, :hot ou :cold.
    def folder_path_schema_tables type = nil
      @folder_path_schema_tables ||= site.folder_database + 'definition_tables_mysql'
      case type
      when NilClass then @folder_path_schema_tables
      when :hot     then @folder_path_schema_tables + 'base_hot'
      when :cold    then @folder_path_schema_tables + 'base_cold'
      end
    end

  end #/<< self

  # ---------------------------------------------------------------------
  #   Instance d'une table de database
  # ---------------------------------------------------------------------
  attr_reader :name
  # Pour savoir si c'est une table :hot ou :cold
  attr_reader :type

  attr_reader :db_name

  # Instanciation de la table, avec son type (dans :hot
  # ou dans :cold — la base) et son nom +table_name+
  def initialize type, table_name
    @name = table_name
    @type = type
  end

  # ---------------------------------------------------------------------
  #   PRINCIPALES REQUÊTES
  # ---------------------------------------------------------------------
  # Pour insérer un enregistrement dans la table
  # (quand il n'existe pas).
  #
  def insert params
    Request::new(self, params).insert
  end

  def select params
    request = <<-SQL
SELECT #{columns_clause params} FROM #{name}
  #{where_clause params}
  #{order_by_clause params}
  #{limit_clause params}
  #{group_clause params}
  ;
    SQL
  end
  def request_select params

  end

  def update params
    request = <<-SQL
UPDATE #{name}
  SET #{set_clause params}
  #{where_clause params}
  #{order_by_clause params}
  #{limit_clause params}
  ;
    SQL
  end

  # Pour SET, il faut savoir si c'est un insert ou un
  # update, donc savoir si la ligne existe.
  def set params

  end
  def get params

  end

  def delete

  end

  #
  # / FIN REQUÊTES PRINCIPALES
  # ---------------------------------------------------------------------

  # Le client ruby qui permet d'intergagir avec la base de
  # données.
  def client
    @client ||= begin
      Mysql2::Client.new(self.class.client_data.merge(database: db_name))
    end
  end

  # Nom de la base de données contenant la table.
  # Soit la base :hot soit la base :cold.
  def db_name
    @db_name = "#{self.class.prefix_name}#{type}"
  end


  # Retourne TRUE si la table existe, FALSE si elle
  # n'existe pas.
  def exists?
    if self.class.tables.key?("#{type}.#{name}")
      true
    else
      begin
        client.query("SELECT 1 FROM #{name} LIMIT 1;")
        true
      rescue Exception => e
        false
      end
    end
  end

  # = main =
  #
  # Fonction principal qui exécute le code voulu.
  #
  def execute request
    client.query(request)
  rescue Exception => e
    debug e
    @error = e
    raise e
  end


  # ---------------------------------------------------------------------
  #   Méthodes de fabrication des clauses
  # ---------------------------------------------------------------------

  # La clause WHERE peut être définie de ces manières
  # suivantes :
  #     - String simple     p.e. 'id = 12'
  #     - String complexe   p.e.  'id = ?'
  #     - Hash              p.e. {id : 12}
  def where_clause params
    where = params[:where]
    case where
    when NilClass then ''
    when String then where
    when Hash then
      # Pour un Hash, on transforme en "key = :key" et on incrémente
      # les valeurs qui devront être bindées
      @values ||= []
      @values = where.values + @values
      where.collect { |k, v| "( #{k} = ? )" }.join(' AND ')
    else
      raise 'La clause WHERE doit être définie par un NIL, un String ou un Hash.'
    end
  end
  def columns_clause params
    columns = params[:columns] || params[:colonnes]
    case columns
    when NilClass then '*'
    when Array    then (columns << :id).uniq.join(', ')
    when String   then columns
    else
      raise 'Le paramètre :colonnes doit être NIL, un Array ou un String.'
    end
  end

  def limit_clause params
    if params.key?(:limit)
      "LIMIT #{params[:limit]}"
    else
      ''
    end
  end
  def group_by_clause params
    if params.key?(:group) || params.key?(:group_by)
      "GROUP BY #{params[:group] || params[:group_by]}"
    else
      ''
    end
  end
  def order_by_clause params
    if params.key?(:order) || params.key?(:order_by)
      "ORDER BY #{params[:order] || params[:order_by]}"
    else
      ''
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes utilitaires
  # ---------------------------------------------------------------------
  # Destruction de la table courante
  # PRUDENCE !
  # Retourne true si la table n'existe plus, false dans le
  # cas contraire.
  def destroy
    client.query("DROP TABLE IF EXISTS #{name}")
    self.class.tables.delete("#{type}.#{name}")
    exists? == false
  end

  def export

  end


  # ---------------------------------------------------------------------
  #   Méthodes utiles à la création de la table
  # ---------------------------------------------------------------------
  # Chemin d'accès au schéma de la base
  def schema_path
    @schema_path ||= self.class.folder_path_schema_tables(type) + "table_#{name}.rb"
  end
  # Le nom du schéma, c'est-à-dire le nom de la méthode
  # qui va renvoyer le code de création de la table.
  def schema_name
    @schema_name ||= "schema_table_#{name}".to_sym
  end
  def code_creation_schema
    @code_creation_schema ||= begin
      schema_path.require
      send(schema_name)
    end
  end
  # Crée la table si elle n'existe pas.
  # RETURN toujours l'instance courante, pour le chainage
  def create_if_needed
    execute( code_creation_schema ) unless exists?
    return self
  end
  #
  # /fin des méthodes pour la création de la table

end #/MDB
end #/SiteHtml
