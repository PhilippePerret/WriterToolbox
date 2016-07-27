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
          # L'erreur sera mise à nil si un quiz est trouvé.
          @error = 'Suffixe de base non fourni'
          get_quiz_courant
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
          if quiz_courants.empty?
            @error = 'Pas de quiz courant dans cette base de données.'
            nil
          else
            qid_current = quiz_courants.first[:id]
            @suffix_base = suffix_base
            new(qid_current)
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
      options ||= {}


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
        nil
      else
        @error = nil
        quiz_courant
      end
    end

  end #/<<self
end #/Quiz
