# encoding: UTF-8
=begin

  Méthodes pour la gestion de la base de données du quiz

  Rappel : le module appelant le quiz doit définir le préfixe
  du nom de la base (dans laquelle seront enregistrées toutes les
  réponses).

=end
class Quiz

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
    @database_relname ||= "quiz_#{prefix_base}"
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
  # pour pouvoir ensuite synchroniser les deux.
  #
  def database_create

    OFFLINE || raise('Un quiz doit se créer obligatoirement sur le site local.')

    require './data/secret/mysql'
    client_data_offline = DATA_MYSQL[:offline]
    client_data_online  = DATA_MYSQL[:online]
    client_offline = Mysql2::Client.new(client_data_offline)
    client_online  = Mysql2::Client.new(client_data_online)

    # Création de la base
    request = 'DROP DATABASE IF EXISTS `#{database_fullname}`;CREATE DATABASE `#{database_fullname}`;'

    res = client_offline.query(request)
    debug "Retour requête offline : #{res.inspect}"
    res = client_online.query(request)
    debug "Retour requête online : #{res.inspect}"


    # where = OFFLINE ? 'DISTANT' : 'LOCAL'
    #
    # # Chemin d'accès aux dossiers contenant le schéma des tables
    # dos_src = './database/definition_tables_mysql/base_quiz'
    # dos_dst = "./database/definition_tables_mysql/base_#{database_relname}"
    #
    # site.mysql_execute("CREATE DATABASE `#{database_fullname}`;") || begin
    #   # Invoqué si la requête a planté
    #   raise "Impossible de créer la base de données #{database_fullname}…"
    # end
    # debug "-> Base de données #{database_fullname} créée."
    # debug "\n\nPOUR CRÉER LA BASE DE DONNÉES :\n\tCREATE DATABASE `#{database_fullname}`;"
    # flash "Vous devez créer la base de données `#{database_fullname}` sur le site #{where}. Le code a été mis dans le debug (chercher : CREATE DATABASE)"
    #
    # # On fait une copie exacte du dossier contenant les schémas
    # # des tables
    # FileUtils.cp_r dos_src, dos_dst
    #
    # # On demande la construction des tables (simplement en les
    # # appelant)
    # debug "\nSI NÉCESSAIRE, APPELER LE CODE SUIVANT POUR CRÉER LES BASES SUR LE SITE #{OFFLINE ? 'DISTANT' : 'LOCAL'} (*)."
    # ['quiz', 'questions', 'resultats'].each do |table_name|
    #   rs = site.dbm_table(database_relname, table_name)
    #   # On la met directement dans l'instance pour gagner du
    #   # temps (et des vérifications)
    #   instance_variable_set("@table_#{table_name}", rs)
    #   debug "\tsite.dbm_table('#{database_relname}', '#{table_name}')"
    # end
    # debug "MAIS ATTENTION, IL EST IMPÉRATIF D'AVOIR *DUPLIQUÉ* LE DOSSIER `./database/definition_tables_mysql/base_quiz` SUR LE SITE #{where}"
    # debug "EN LE RENOMMANT : `base_#{database_relname}`"

  rescue Exception => e
    debug e
    error e.message
  else
    @database_is_existing = true
  ensure
    # # Dans tous les cas…
    # # On détruit le dossier contenant les schémas des tables
    # # dans le dossier provisoire de la base (qui ne servira plus)
    # FileUtils.rm_rf(dos_dst) if File.exist?(dos_dst)
  end

end #/Quiz
