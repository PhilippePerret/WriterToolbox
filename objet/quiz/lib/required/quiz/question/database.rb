# encoding: UTF-8
class Quiz
  class Question

    # Table contenant toutes les questions dans la base
    # de données du questionnaire auquel appartient cette
    # question
    def table
      @table ||= site.dbm_table(database_relname, 'questions')
    end
    alias :table_questions :table

    def database_relname
      @database_relname ||= begin
        if quiz.nil? # <= question éditée hors d'un quiz
          "quiz_#{Quiz.suffix_base}".to_sym
        else
          quiz.database_relname
        end
      end
    end

  end #/Question
end #/Quiz
