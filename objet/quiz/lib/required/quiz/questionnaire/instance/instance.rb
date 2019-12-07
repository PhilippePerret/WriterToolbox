# encoding: UTF-8
class Quiz

  # Pour empêcher d'initialiser le quiz à partir de l'url
  # Si on le permettait, il y aurait une erreur générée du fait que
  # l'instanciation attend deux arguments et non pas seulement
  # l'identifiant
  NO_INSTANCIATION_BY_URL = true

  # ID du questionnaire dans la base, donc dans la table 'quiz'
  # de la base de données courante.
  attr_reader :id

  # +qid+ Identifiant du quiz dans sa base de données.
  #
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
