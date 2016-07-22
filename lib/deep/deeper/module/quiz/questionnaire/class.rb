# encoding: UTF-8
class ::Quiz
  class << self

    # Retourne l'instance du questionnaire courant
    #
    # Rappel : le questionnaire courant est le questionnaire
    # qui a '1' en premier bit d'options.
    #
    def current
      @current ||= begin
        if suffix_base.nil?
          nil
        else
          drequest = {
            where: "SUBSTRING(options,1,1) = '1' ",
            limit: 1,
            colonnes: []
          }
          qid_current = table_quiz.select(drequest).first[:id]
          debug "qid_current = #{qid_current}"
          new(qid_current)
        end
      end
    end

    def table_quiz
      @table_quiz ||= site.dbm_table("quiz_#{suffix_base}", 'quiz')
    end

    def suffix_base
      @suffix_base ||= param(:qdbr).nil_if_empty
    end

  end #/<<self
end #/Quiz
