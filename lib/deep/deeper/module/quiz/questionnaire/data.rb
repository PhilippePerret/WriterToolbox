# encoding: UTF-8
=begin

  Module pour les données (absolues) du questionnaire

=end
class Quiz

  include MethodesMySQL


  # ---------------------------------------------------------------------
  #   DATA enregistrées
  # ---------------------------------------------------------------------
  def titre; @titre ||= get(:titre) end
  def groupe; @groupe ||= get(:groupe) end
  def options; @options ||= get(:options) end
  def questions_ids; @questions_ids ||= (get(:questions_ids) || '').split(' ') end
  def description; @description ||= get(:description) end
  def created_at; @created_at ||= get(:created_at) end
  def updated_at; @updated_at ||= get(:updated_at) end

  # ---------------------------------------------------------------------
  #   DATA volatiles
  # ---------------------------------------------------------------------

  # Array ordonné des questions
  def questions

  end

  # ---------------------------------------------------------------------
  # Méthode de données
  # ---------------------------------------------------------------------


end
