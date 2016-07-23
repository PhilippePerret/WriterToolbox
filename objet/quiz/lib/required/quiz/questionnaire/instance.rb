# encoding: UTF-8
class ::Quiz

  # ID du questionnaire dans la base, donc dans la table 'quiz'
  # de la base de données courante.
  attr_reader :id

  def initialize qid
    @id = qid
  end

  # Retourne true si le questionnaire existe déjà
  #
  # Noter que l'ID peut avoir été défini à l'instanciation sans
  # que le questionnaire existe encore.
  def exist?
    return id != nil && table_quiz.get(id) != nil
  end

end
