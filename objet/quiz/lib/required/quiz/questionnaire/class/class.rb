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
      debug "-> current"
      @current ||= begin
        debug "-> begin de current"
        if suffix_base.nil?
          debug "-> suffix_base est nil"
          # On essaie d'obtenir ce suffixe en checkant toutes les
          # bases de données. Si on le trouve, on retourne l'instance
          # Quiz du questionnaire.
          # L'erreur sera mise à nil si un quiz est trouvé.
          @error = 'Suffixe de base non fourni'
          get_quiz_courant
        elsif !database_exist?
          @error = 'Base de données inexistante avec le suffixe fourni'
          get_quiz_courant
        else
          drequest = {
            where: "SUBSTRING(options,1,1) = '1' ",
            # where: "options LIKE '1%'",
            limit: 1,
            colonnes: []
          }
          quiz_courants = table_quiz.select(drequest)
          if quiz_courants.empty?
            @error = 'Pas de quiz courant dans cette base de données.'
            get_quiz_courant
          else
            qid_current = quiz_courants.first[:id]
            @suffix_base = suffix_base
            new(qid_current)
          end
        end
      end
      @current != nil || raise('LE QUIZ COURANT NE DEVRAIT JAMAIS POUVOIR ÊTRE NUL')
      @current
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
    # Il peut être défini explicitement par les test avec
    # Quiz.suffix_base=
    def suffix_base
      @suffix_base ||= param(:qdbr).nil_if_empty
    end
    def suffix_base= value; @suffix_base = value end

    # Méthode qui cherche le quiz courant
    # Elle retourne soit l'instance du Quiz trouvé, soit nil.
    # (il est impératif de trouver un de ces deux valeurs seulement)
    #
    # +options+
    #   :but      Si précisé, c'est l'ID qu'il faut écarter de la
    #             recherche.
    def get_quiz_courant options = nil
      debug "-> get_quiz_courant"
      options ||= Hash.new
      # On regarde dans ces bases s'il y a un quiz courant. Si c'est le
      # cas, on le prend.
      quiz_courant = nil
      where = "SUBSTRING(options,1,1) = '1'"
      where += " AND id != #{options[:but]}" if options[:but]
      drequest = {
        where: where,
        limit: 1,
        order: 'created_at DESC',
        colonnes: []
      }
      all_suffixes_quiz.each do |sufbase|
        dquiz = site.dbm_table("quiz_#{sufbase}", 'quiz').select(drequest).first
        dquiz != nil || next
        quiz_courant = ::Quiz.new(dquiz[:id])
        @suffix_base = sufbase
        break
      end

      # S'il n'y a aucun quiz courant, on signale l'erreur
      if quiz_courant.nil?
        debug "quiz_courant est nil"
        # On fait une dernière tentative en prenant le dernier quiz
        very_last_quiz
      else
        @error = nil
        quiz_courant
      end
    end

    # {Quiz} Retourne le tout dernier quiz, sans le mettre en
    # quiz courant.
    def very_last_quiz
      debug "-> very_last_quiz"
      l = allquiz.sort_by{|q| q.created_at}.last
      debug "ID : #{l.id} / CLASS: #{l.class}"
      l
    end

  end #/<<self
end #/Quiz
