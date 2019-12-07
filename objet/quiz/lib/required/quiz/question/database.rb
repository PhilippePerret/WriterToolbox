# encoding: UTF-8
class Quiz
  class Question

    # Table contenant toutes les questions dans la base
    # de données du questionnaire auquel appartient cette
    # question
    def table
      @table ||= site.dbm_table(:quiz, 'questions')
    end
    alias :table_questions :table

  end #/Question
end #/Quiz
