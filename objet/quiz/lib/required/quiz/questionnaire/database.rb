# encoding: UTF-8
=begin

  Méthodes pour la gestion de la base de données du quiz

  Rappel : le module appelant le quiz doit définir le préfixe
  du nom de la base (dans laquelle seront enregistrées toutes les
  réponses).

=end
class Quiz

  class << self

    # Tous les suffixes de bases de données dans toutes les
    # bases de données du site.
    def all_suffixes_quiz
      @all_suffixes_quiz ||= begin
        SiteHtml::DBM_TABLE.databases.collect do |dbname|
          dbname.start_with?("#{SiteHtml::DBBASE_PREFIX}quiz_") || (next nil)
          dbname.sub(/#{Regexp.escape SiteHtml::DBBASE_PREFIX}quiz_/o, '')
        end.compact
      end
    end


  end #/ << self Quiz

  # Le suffixe base qui permettra de savoir dans quelle base est
  # enregistré le questionnaire.
  # Ce suffixe peut être déterminé soit :
  #   - par l'url avec le paramètre 'qdbr' (privilégié)
  #   - par `quiz.suffix_base = `
  def suffix_base; @suffix_base || self.class.suffix_base end


  def table_resultats
    @table_resultats ||= begin
      database_exist? || database_create
      site.dbm_table(database_relname, 'resultats')
    end
  end

  def table_questions
    @table_questions ||= begin
      database_exist? || database_create
      site.dbm_table(database_relname, 'questions')
    end
  end

  # Pour les données de toutes les quiz
  def table_quiz
    @table_quiz ||= begin
      database_exist? || database_create
      site.dbm_table(database_relname, 'quiz')
    end
  end
  alias :table :table_quiz

  # Le nom de la base de données en fonction du préfixe définies
  # par le module appelant
  def database_relname
    @database_relname ||= "quiz_#{suffix_base}"
  end
  def database_fullname
    @database_fullname ||= "boite-a-outils_#{database_relname}"
  end


  # ---------------------------------------------------------------------
  #   Méthodes pour la construction de la base de données si elle
  #   n'existe pas encore.
  #
  #   Les schémas des tables se trouvent dans base_quiz et portent
  #   les noms normaux. Dans l'idée, il suffirait de modifier le nom
  #   du dossier pour que le site puisse les trouver automatiquement.
  #   C'est ce que je fais essayer de faire
  # ---------------------------------------------------------------------

  # Retourne true si la base de données existe déjà
  def database_exist?
    if @database_is_existing === nil
      @database_is_existing = SiteHtml::DBM_TABLE.database_exist?(database_fullname)
    end
    @database_is_existing
  end

  # Construction de la base de données si elle n'existe pas
  # encore. On ne fait pas le test de l'existence ici, il faut
  # le faire avant d'appeler cette méthode.
  #
  # La méthode se sert des schémas de tables définis dans le
  # dossier `base_quiz`, construit un dossier provisoire à partir de
  # ce dossier en lui donnant le nom de cette base de données courantes
  # pour que les méthodes dbm du site puisse construire les tables.
  #
  # Noter qu'il faut également créer la base et les tables en online
  # pour pouvoir ensuite synchroniser les deux. MAIS comme il semble
  # que l'on ne puisse pas créer de base sur le site distant de cette
  # façon là, il faut d'abord le faire manuellement
  #
  def database_create

    OFFLINE || raise('Un quiz doit se créer obligatoirement sur le site local.')

    # La base de données distante doit exister pour pouvoir
    # procéder à la création. On la crée par CURL et par l'API de
    # alwaysdata
    database_online_exist? || create_database_online
    # On vérifie que la base a bien été créée.
    database_online_exist? || raise("La base ONLINE `#{database_fullname}` n'existe pas, après création par l'API d'always data… Cela doit peut-être être fait depuis le tableau de bord alwaydata.")

    debug "NOM DATABASE : #{database_fullname}"

    # Création de la base locale
    ["DROP DATABASE IF EXISTS `#{database_fullname}`;", "CREATE DATABASE `#{database_fullname}`;"
    ].each do |request|
      res = client_offline.query(request)
    end

    if database_offline_exists?
      debug "Base locale créée avec succès."
    else
      raise('la base locale n’a pas été créée, je dois abandonner.')
    end

    # Maintenant, on va créer les tables dans la base online et la
    # base offline

    # On utilise la base de donnée
    client_offline.query("USE `#{database_fullname}`")
    client_online.query("USE `#{database_fullname}`")

    # Le dossier source contenant la définition des schémas des
    # tables.
    dos_src = './database/definition_tables_mysql/base_quiz'
    Dir["#{dos_src}/table_*.rb"].each do |ftable|
      tb_name = File.basename(ftable, File.extname(ftable)).sub(/^table_/,'')
      debug "CRÉATION TABLE : #{tb_name}"
      # On prend le code de création de la table
      require ftable
      code_creation_table = send("schema_table_#{tb_name}".to_sym)
      # Création de la table
      client_offline.query(code_creation_table + ';')
      client_online.query("DROP TABLE IF EXISTS #{tb_name}")
      client_online.query(code_creation_table + ';')
    end

  rescue Exception => e
    debug e
    @database_is_existing = false
    error e.message
  else
    @database_is_existing = true
  end

  def client_online
    @client_online ||= begin
      require './data/secret/mysql'
      Mysql2::Client.new( DATA_MYSQL[:online] )
    end
  end
  def client_offline
    @client_offline ||= begin
      require './data/secret/mysql'
      Mysql2::Client.new( DATA_MYSQL[:offline] )
    end
  end

  # Pour la création de la base de données ONLINE, il faut
  # passer par l'API de AlwaysData
  def create_database_online
    require './data/secret/api_alwaysdata'
    url = 'https://api.alwaysdata.com/v1/database/'
    datacmd = '{"encoding": "utf8", "name": "' + database_fullname + '", "type": "MYSQL", "permissions": {"118479": "NONE", "118479_phil": "FULL", "118479_user": "READONLY"}}'
    cmd = "CURL --basic --user #{AD_API[:api_key]}: #{url} --request POST --data '#{datacmd}'"
    debug "CMD : #{cmd}"
    res = `#{cmd} 2>&1`
    debug "RETOUR CURL CRÉATION DATABASE #{database_fullname} ONLINE : #{res.inspect}"
  end

  # Return true si la base online existe.
  #
  # On utilise maintenant l'API d'alwaysdata pour avoir
  # une liste correcte des bases de données.
  #
  def database_online_exist?
    require './data/secret/api_alwaysdata'
    url = 'https://api.alwaysdata.com/v1/database/'
    cmd = "CURL --basic --user #{AD_API[:api_key]}: #{url}"
    res = `#{cmd}`
    # debug "RETOUR CURL DATABASES : #{res.inspect}"
    JSON.load(res).each do |hdb|
      return true if hdb['name'] == database_fullname
    end
    return false
  end

  def database_offline_exists?
    client_offline.query('SHOW DATABASES;').each do |row|
      debug "Database offline : #{row['Database']}"
      return true if row['Database'] == database_fullname
    end
    return false
  end

end #/Quiz
