# encoding: UTF-8
class Unan
class Quiz

  include MethodesObjetsBdD

  attr_reader :id
  def initialize id
    @id = id
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def titre         ; @titre          ||= get(:titre)         end
  def type          ; @type           ||= get(:type)          end
  def questions_ids ; @questions_ids  ||= get(:questions_ids) end
  def description   ; @description    ||= get(:description)   end
  def options       ; @options        ||= get(:options)       end
  def points        ; @points         ||= get(:points)        end
  # ---------------------------------------------------------------------
  #   Données volatiles
  # ---------------------------------------------------------------------
  def human_type
    @human_type ||= TYPES[type][:hname]
  end

  # {Array} Retourne la liste des instances Unan::Quiz::Question des
  # questions du questionnaires.
  def questions
    @questions ||= begin
      questions_ids.split(' ').collect{|qid| Question::new(qid.to_i, self.id)}
    end
  end

  # {Fixnum|Nil} Nombre de points maximum pour ce questionnaire, ou
  # nil si aucun point n'est à attribuer.
  # Note : Ne tient pas compte de la valeur `points` qui peut être
  # définie optionnellement.
  def max_points
    @max_points ||= begin
      mp = 0
      questions.each { |q| mp += q.max_points unless q.max_points.nil? }
      mp = nil if mp == 0
      mp
    end
  end

  # Retourne les points marqués pour ce quiz, i.e. les points pour les
  # questions s'il y en a + les points spécialement du questionnaire
  def quiz_points
    @quiz_points ||= begin
      pts = 0
      pts += (user_points || 0) unless only_points_quiz?
      pts += (points || 0)
      pts
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes de version
  # ---------------------------------------------------------------------
  def previous_version
    @previous_version ||= begin
      previous_version_id.nil? ? nil : Unan::Quiz::new(previous_version_id)
    end
  end
  def next_version
    @next_version ||= begin
      next_version_id.nil? ? nil : Unan::Quiz::new(next_version_id)
    end
  end

  # ---------------------------------------------------------------------
  #   Base de données
  # ---------------------------------------------------------------------
  def table   ; @table ||= Unan::table_quiz end

end #/Quiz
end #/Unan
