# encoding: UTF-8
class ::Quiz

  # ID du questionnaire dans la base, donc dans la table 'quiz'
  # de la base de données courante.
  attr_reader :id

  def initialize qid
    @id = qid
  end


end
