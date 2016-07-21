# encoding: UTF-8
class ::Quiz
  class Question

    # Instance {Quiz} du quiz possédant cette question
    attr_reader :quiz

    # ID de la question dans la table des questions, ou nil
    attr_reader :id


    def initialize quiz, qid = nil
      @quiz = quiz
      @id   = id
    end

  end #/Question
end #/Quiz
