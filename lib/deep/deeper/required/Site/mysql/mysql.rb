# encoding: UTF-8
require 'mysql2'

class SiteHtml

  # Retourne l'instance SiteHtml::DBM_TABLE de la table MySQL
  def dbm_table db_name, table_name, force_online = false
    DBM_TABLE.get(db_name.to_sym, table_name, force_online)
  end

class DBM_TABLE # DBM_TABLE pour DataBase Mysql

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self

    attr_reader :tables

    # Retourne la table (instance {SiteHtml::DBM_TABLE}) de nom
    # +tablename+ dans la base de type +db_type+ qui peut
    # être :hot, :cold, :cnarration, :unan.
    def get db_type, tablename, force_online = false
      @tables ||= {}
      @tables["#{db_type}.#{tablename}#{force_online ? '' : '.online'}"] ||= begin
        new(db_type, tablename, force_online).create_if_needed
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
      @client_data ||= ( OFFLINE ? client_data_offline : client_data_online )
    end

    def client_data_offline
      require './data/secret/mysql'
      DATA_MYSQL[:offline]
    end

    def client_data_online
      require './data/secret/mysql'
      DATA_MYSQL[:online]
    end

    # Le préfixe du nom (de la base de données) en fonction
    # du fait qu'on est online ou offline
    #
    # Normalement, maintenant, on peut utiliser les deux en
    # online comme en offline.
    #
    def prefix_name
      @prefix_name ||= 'boite-a-outils_'
    end

    # {SuperFile} Dossier contenant les schémas des
    # tables des bases de données.
    # Elles sont réparties en deux dossier, :hot ou :cold.
    def folder_path_schema_tables type = nil
      @folder_path_schema_tables ||= site.folder_database + 'definition_tables_mysql'
      type ? @folder_path_schema_tables + "base_#{type}" : @folder_path_schema_tables
    end

  end #/<< self

  # ---------------------------------------------------------------------
  #   Instance d'une table de database
  # ---------------------------------------------------------------------
  attr_reader :name
  # Pour savoir si c'est une table :hot, :cold, :cnarration,
  # etc.
  attr_reader :type

  attr_reader :db_name

  # Si True, c'est avec les bases online qu'on travaille
  attr_reader :force_online

  # Instanciation de la table, avec son type (dans :hot
  # ou dans :cold — la base) et son nom +table_name+
  #
  # +force_online+ permet de forcer l'interaction avec
  # la base online (pour la synchronisation par exemple)
  #
  def initialize type, table_name, force_online = false
    @name           = table_name
    @type           = type
    @force_online   = force_online
    # debug "@name: #{@name.inspect} / @type: #{@type.inspect} / @force_online: #{@force_online.inspect}"
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
  def select params = nil, options = nil
    Request.new(self, params, options).select
  end
  def get who, options = nil
    Request.new(self, who, options).get
  end
  def update who, values
    Request.new(self, who, values).update
  end
  def set who, values
    Request.new(self, who, values).set
  end
  def delete who = nil
    Request.new(self, who).delete
  end
  def count who = nil
    Request.new(self, who).count
  end


  #
  # / FIN REQUÊTES PRINCIPALES
  # ---------------------------------------------------------------------

  # Le client ruby qui permet d'intergagir avec la base de
  # données.
  def client
    @client ||= begin
      Mysql2::Client.new(client_data.merge(database: db_name))
    end
  end
  def client_data
    if force_online
      self.class.client_data_online
    else
      self.class.client_data
    end
  end

  # Nom de la base de données contenant la table.
  # Soit la base :hot soit la base :cold.
  def db_name
    @db_name ||= "#{self.class.prefix_name}#{type}"
  end

  # Retourne TRUE si la table existe, FALSE si elle
  # n'existe pas.
  def exists?
    if self.class.tables.key?("#{type}.#{name}#{force_online ? '' : '.online'}")
      true
    else
      force_query_existence
    end
  end
  alias :exist? :exists?

  def force_query_existence
    begin
      client.query("SELECT 1 FROM #{name} LIMIT 1;")
      true
    rescue Exception => e
      false
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

  # ---------------------------------------------------------------------
  #   Méthodes utiles à la création de la table
  # ---------------------------------------------------------------------

  # Lorsque c'est une table dans :users_tables, le nom
  # est composé de <nom table>_<id user>.
  # Il faut prendre le préfixe pour obtenir le nom de la table
  # pour trouver sa définition et son code de création.
  # Il faut prendre le suffixe, donc l'ID de l'user pour pour
  # envoyer à la création pour composer une table qui s'appellera
  # bien <nom table>_<id user>, donc une table unique pour l'user
  def prefix_name
    @prefix_name || split_name
  end
  def suffix_name # en fait = l'ID de l'user
    @suffix_name || split_name
    @suffix_name
  end
  def split_name
    dname = name.split('_')
    @suffix_name = dname.pop
    @prefix_name = dname.join('_')
  end

  # Chemin d'accès au schéma de la base
  def schema_path
    @schema_path ||= begin
      sp =
        if type == :users_tables
          self.class.folder_path_schema_tables(type) + "table_#{prefix_name}.rb"
        else
          self.class.folder_path_schema_tables(type) + "table_#{name}.rb"
        end
      sp.exist? || raise("Le schéma de la table (#{sp}) est introuvable…")
      sp
    end
  end
  # Le nom du schéma, c'est-à-dire le nom de la méthode
  # qui va renvoyer le code de création de la table.
  def schema_name
    @schema_name ||= begin
      if type == :users_tables
        "schema_table_#{prefix_name}".to_sym
      else
        "schema_table_#{name}".to_sym
      end
    end
  end

  def code_creation_schema
    @code_creation_schema ||= begin
      schema_path.require
      if type == :users_tables
        send(schema_name, suffix_name)
      else
        send(schema_name)
      end
    end
  end
  # Crée la table si elle n'existe pas.
  # RETURN toujours l'instance courante, pour le chainage
  def create_if_needed
    create unless exists?
    return self
  end

  def create
    client.query( code_creation_schema )
    if force_query_existence
      debug "Table #{name} créée avec succès dans #{db_name}"
    else
      raise("La table #{name} n'a pas été crée, dans #{db_name}…")
    end
  end
  #
  # /fin des méthodes pour la création de la table

end #/MDB
end #/SiteHtml
