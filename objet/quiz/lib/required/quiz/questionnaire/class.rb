# encoding: UTF-8
class ::Quiz

  # Les méthodes principales de n'importe quel objet RestSite
  extend MethodesMainObjets

  class << self

    attr_reader :error

    # Retourne l'instance du questionnaire courant
    #
    # Rappel : le questionnaire courant est le questionnaire
    # qui a '1' en premier bit d'options.
    #
    # Si la base n'est pas définie (par suffix_base, avec dqbr en
    # paramètre) alors on cherche le premier quiz courant dans toutes
    # les bases.
    #
    def current
      @current ||= begin
        if suffix_base.nil?
          # On essaie d'obtenir ce suffixe en checkant toutes les
          # bases de données. Si on le trouve, on retourne l'instance
          # Quiz du questionnaire.
          cherche_quiz_courant
        elsif !database_exist?
          @error = 'Base de données inexistante avec le suffixe fourni'
          nil
        else
          drequest = {
            where: "SUBSTRING(options,1,1) = '1' ",
            # where: "options LIKE '1%'",
            limit: 1,
            colonnes: []
          }
          quiz_courants = table_quiz.select(drequest)
          debug "quiz_courants : #{quiz_courants.inspect}"
          if quiz_courants.empty?
            @error = 'Pas de quiz courant dans cette base de données.'
            nil
          else
            qid_current = quiz_courants.first[:id]
            debug "qid_current = #{qid_current}"
            q = new(qid_current)
            q.suffix_base= suffix_base
            q
          end
        end
      end
    end

    def table_quiz
      @table_quiz ||= site.dbm_table("quiz_#{suffix_base}", 'quiz')
    end

    def database_exist?
      SiteHtml::DBM_TABLE.database_exist?("boite-a-outils_quiz_#{suffix_base}")
    end

    # Suffix du nom de la base courant
    # {String ou Nil}
    #
    # IL est contenu dans la variable qdbr (qui signifie "q" pour "quiz",
    # "db" pour "database" et "r" pour relname, le nom relatif, sans 'quiz'
    # et sans la racine des bases de données — 'boite-a-outils' pour le BOA)
    #
    def suffix_base
      @suffix_base ||= param(:qdbr).nil_if_empty
    end

    # Méthode qui cherche le quiz courant
    # Elle retourne soit l'instance du Quiz trouvé, soit nil.
    # (il est impératif de trouver un de ces deux valeurs seulement)
    def cherche_quiz_courant

      # On va commencer par chercher les bases de données
      # qui sont des quiz.
      suffixes_quiz = Array.new
      SiteHtml::DBM_TABLE.databases.each do |dbname|
        dbname.start_with?("#{SiteHtml::DBBASE_PREFIX}quiz_") || next
        suffixes_quiz << dbname.sub(/#{Regexp.escape SiteHtml::DBBASE_PREFIX}quiz_/o, '')
      end

      # On regarde dans ces bases s'il y a un quiz courant. Si c'est le
      # cas, on le prend.
      quiz_courant = nil
      drequest = {
        where: "SUBSTRING(options,1,1) = '1'",
        limit: 1,
        order: 'created_at DESC',
        colonnes: []
      }
      suffixes_quiz.each do |sufbase|
        dquiz = site.dbm_table("quiz_#{sufbase}", 'quiz').select(drequest).first
        dquiz != nil || next
        quiz_courant = ::Quiz.new(dquiz[:id])
        @suffix_base = sufbase
        break
      end

      # S'il n'y a aucun quiz courant, on signale l'erreur
      if quiz_courant.nil?
        @error = 'Suffixe de base non fourni'
        nil
      else
        quiz_courant
      end
    end

  end #/<<self
end #/Quiz
