# encoding: UTF-8
class Unan
class Quiz
class Question

  include MethodesObjetsBdD

  attr_reader :id

  # {Fixnum} Peut-être défini
  attr_reader :quiz_id

  # +qid+ ID de la question dans la table
  # +quiz_id+ ID du questionnaire qui contient cette question, si
  # on est en train de le construire (mais dans l'absolu, une
  # question n'appartient jamais à un questionnaire en particulier)
  def initialize qid, quiz_id = nil
    @id       = qid.to_i
    @quiz_id  = quiz_id
  end

  # Retourne true si la question existe
  def exist?
    table.count(where:{id: id}) > 0
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def question    ; @question   ||= get(:question)  end
  # Noter que les réponses sont un Hash, tout simplement parce
  # que BdD essaie de se comporter intelligemment et reconnait un
  # Array. Donc il faut penser à le passer par json pour l'enregistrer
  def reponses    ; @reponses   ||= get(:reponses)  end
  def indication  ; @indication ||= get(:indication)  end
  def raison      ; @raison     ||= get(:raison)    end
  def type        ; @type       ||= get(:type)      end

  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------
  # Type de choix ("c" pour cases à cocher, "r" pour radio)
  def type_c  ; @type_c ||= type[0] end
  # Type d'affichage ("l" pour en ligne, "c" pour en colonne, "m" pour
  # en menu)
  def type_a  ; @type_a ||= type[1] end
  # Le type de questions
  # Pour savoir si c'est une question de simple renseignement,
  # ou une question de quiz, etc.
  # Cf. la liste Unan::Quiz::TYPES, qui est la même que pour le
  # type de quiz
  def type_f  ; @type_f ||= type[2] end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------

  def max_points
    @max_points ||= reponses.collect { |hrep| hrep[:points] }.max
  end

  # ---------------------------------------------------------------------
  #   Méthodes de database
  # ---------------------------------------------------------------------
  def table ; @table ||= Unan::table_questions end

end #/Question
end #/Quiz
end #/Unan
