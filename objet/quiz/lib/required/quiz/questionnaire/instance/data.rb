# encoding: UTF-8
=begin

  Module pour les données (absolues) du questionnaire

=end
class Quiz

  include MethodesMySQL

  # ---------------------------------------------------------------------
  #   DATA enregistrées
  # ---------------------------------------------------------------------
  def titre       ; @titre        ||= get(:titre)       end
  def groupe      ; @groupe       ||= get(:groupe)      end
  def type        ; @type         ||= get(:type)        end
  def options     ; @options      ||= get(:options) || default_options end
  def description ; @description  ||= get(:description) end
  def created_at  ; @created_at   ||= get(:created_at)  end
  def updated_at  ; @updated_at   ||= get(:updated_at)  end
  # Liste des identifiants de questions
  # Noter que c'est une list de Fixnum
  def questions_ids
    @questions_ids ||= begin
      (get(:questions_ids) || '').split(' ').collect{|e| e.to_i}
    end
  end

  # Les données générales du quiz
  # Donc dans la table :cold 'quiz'
  def data_generales
    @data_generales ||= begin
      whereclause = "quiz_id = #{id} AND suffix_base = '#{suffix_base}'"
      site.dbm_table(:cold, 'quiz').get(where: whereclause)
    end
  end

  # ---------------------------------------------------------------------
  #   DATA volatiles
  # ---------------------------------------------------------------------


end
