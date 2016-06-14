# encoding: UTF-8
require 'mysql2'

class SiteHtml

  # Retourne l'instance SiteHtml::DBM de la table MySQL
  def dbm_table db_name, table_name
    DBM.get(db_name.to_sym, table_name)
  end

class DBM # DBM pour DataBase Mysql

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self

    attr_reader :tables
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

    def client_data
      @client_data ||= begin
        require './data/secret/mysql'
        OFFLINE ? DATA_MYSQL[:offline] : DATA_MYSQL[:online]
      end
    end

    # Le préfixe du nom (de la base de données) en fonction
    # du fait qu'on est online ou offline
    def prefix_name
      @prefix_name ||= (ONLINE ? 'boite-a-outils' : 'boite_outils_auteur') + '_'
    end

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

  def initialize type, table_name
    @name = table_name
    @type = type
  end

  def client
    @client ||= begin
      Mysql2::Client.new(self.class.client_data.merge(database: db_name))
    end
  end

  def db_name
    @db_name = "#{self.class.prefix_name}#{type}"
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


  def insert params
    request = <<-SQL
INSERT INTO #{name}
    SQL
  end

  def select params
    request = <<-SQL
SELECT #{columns_clause params}
  FROM #{name}
  #{where_clause params}
  #{order_by_clause params}
  #{limit_clause params}
  #{group_clause params}
    SQL
  end

  def update params
    request = <<-SQL
UPDATE #{name}
  SET #{set_clause params}
  #{where_clause params}
  #{order_by_clause params}
  #{limit_clause params}
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

  # ---------------------------------------------------------------------
  #   Méthodes de fabrication des clauses
  # ---------------------------------------------------------------------
  def columns_clause params
    ''
  end
  def where_clause params
    ''
  end
  def limit_clause params
    if params.key?(:limit)
      "LIMIT #{params :limit}"
    else
      ''
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

  def destroy

  end

  def export

  end

end #/MDB
end #/SiteHtml
