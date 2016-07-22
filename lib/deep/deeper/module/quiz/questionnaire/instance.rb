# encoding: UTF-8
class ::Quiz

  # ID du questionnaire dans la base, donc dans la table 'quiz'
  # de la base de données courante.
  attr_reader :id

  def initialize qid
    @id = qid
  end

  # Le suffixe base qui permettra de savoir dans quelle base est
  # enregistré le questionnaire.
  # Ce suffixe peut être déterminé soit par `quiz.suffix_base = `
  # soit par une méthode def suffix_base; valeur end qui surclassera
  # la méthode courante
  def suffix_base; @suffix_base end
  def suffix_base= value; @suffix_base = value end


  # Retourne true si le questionnaire existe déjà
  #
  # Noter que l'ID peut avoir été défini à l'instanciation sans
  # que le questionnaire existe encore.
  def exist?
    return id != nil && table_quiz.get(id) != nil
  end

end
