# encoding: UTF-8
=begin
Noter que ça ne concerne qu'une question dans un quiz, pas en dehors
=end
class Quiz
  class Question

    # Instance {Quiz} du quiz possédant cette question
    attr_reader :quiz

    # ID de la question dans la table des questions, ou nil
    attr_reader :id


    def initialize quiz, qid = nil
      @quiz = quiz
      @id   = qid.to_i
      @id > 0 || raise('Impossible d’instancier une question d’identifiant 0.')
    end

  end #/Question
end #/Quiz
