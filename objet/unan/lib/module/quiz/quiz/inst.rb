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

  # ---------------------------------------------------------------------
  #   Méthodes de version
  # ---------------------------------------------------------------------
  def previous_version
    @previous_version ||= begin
      previous_version_id.nil? ? nil : Unan::Quiz::new(previous_version_id)
    end
  end
  def previous_version_id
    @previous_version_id ||= begin
      vip = options[3..8].to_i
      vip = nil if vip == 0
      vip
    end
  end
  def next_version
    @next_version ||= begin
      next_version_id.nil? ? nil : Unan::Quiz::new(next_version_id)
    end
  end
  def next_version_id
    @next_version_id ||= begin
      vip = options[9..14].to_i
      vip = nil if vip == 0
      vip
    end
  end

  # ---------------------------------------------------------------------
  #   Base de données
  # ---------------------------------------------------------------------
  def table   ; @table ||= Unan::table_quiz end

end #/Quiz
end #/Unan
