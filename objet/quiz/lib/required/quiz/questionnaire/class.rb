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
    def current
      @current ||= begin
        if suffix_base.nil?
          @error = 'Suffixe de base non fourni'
          nil
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

  end #/<<self
end #/Quiz
