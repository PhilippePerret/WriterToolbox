# encoding: UTF-8
class Unan
class Quiz
class Question

  include MethodesObjetsBdD

  attr_reader :id

  # +qid+ ID de la question dans la table
  def initialize qid
    @id = qid.to_i
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def question  ; @question   ||= get(:question)  end
  def reponses  ; @reponses   ||= get(:reponses)  end
  def raison    ; @raison     ||= get(:raison)    end
  def type      ; @type       ||= get(:type)      end

  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------
  def type_c  ; @type_c ||= type[0] end
  def type_a  ; @type_a ||= type[1] end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------

  # ---------------------------------------------------------------------
  #   Méthodes de database
  # ---------------------------------------------------------------------
  def table ; @table ||= Unan::table_questions end
  
end #/Question
end #/Quiz
end #/Unan
