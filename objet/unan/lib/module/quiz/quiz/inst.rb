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
      questions_ids.split(' ').collect{|qid| Question::new(qid.to_i)}
    end
  end

  # ---------------------------------------------------------------------
  #   Base de données
  # ---------------------------------------------------------------------
  def table   ; @table ||= Unan::table_quiz end

end #/Quiz
end #/Unan