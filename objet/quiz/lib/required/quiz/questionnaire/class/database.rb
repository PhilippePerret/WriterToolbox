# encoding: UTF-8
=begin

  Méthodes pour la gestion de la base de données du quiz

  Rappel : le module appelant le quiz doit définir le préfixe
  du nom de la base (dans laquelle seront enregistrées toutes les
  réponses).

=end
class Quiz

  def table_resultats
    @table_resultats ||= site.dbm_table(:quiz, 'resultats')
  end

  def table_questions
    @table_questions ||= site.dbm_table(:quiz, 'questions')
  end

  # Pour les données de toutes les quiz
  def table_quiz
    @table_quiz ||= site.dbm_table(:quiz, 'quiz')
  end
  alias :table :table_quiz

end #/Quiz
