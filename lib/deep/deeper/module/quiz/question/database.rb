# encoding: UTF-8
class ::Quiz
  class Question

    # Table contenant toutes les questions dans la base
    # de données du questionnaire auquel appartient cette
    # question
    def table
      @table ||= site.dbm_table(database_relname, 'questions')
    end
    alias :table_questions :table

    def database_relname
      @database_relname ||= quiz.database_relname
    end

  end #/Question
end #/Quiz
