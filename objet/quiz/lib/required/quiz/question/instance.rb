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
      # debug "-> Quiz::Question#initialize( qid = #{qid.inspect})"
      @quiz = quiz
      @id   = qid.to_i
      # Non, @id est nil à la création d'une nouvelle question (plus exactement,
      # quand on affiche le formulaire complet du quiz)
      # @id > 0 || error('Impossible d’instancier une question d’identifiant 0.')
    end

  end #/Question
end #/Quiz
