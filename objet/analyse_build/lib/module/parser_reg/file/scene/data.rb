# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # Identifiant de la scène (donc son numéro)
  # Il sera attribué lors de l'enregistrement.
  attr_accessor :id

  # Données de la première ligne, décomposées
  attr_reader :horloge
  attr_reader :time
  attr_reader :effet
  attr_reader :lieu
  attr_reader :decor
  attr_reader :resume

  attr_reader :data_paragraphes
  attr_reader :notes

  # Toutes les données sous forme de Hash qui doivent être enregistrées
  # dans le fichier Marshal
  def all_data
    {
      id:                 id,
      horloge:            horloge,
      time:               time,
      effet:              effet,
      lieu:               lieu,
      decor:              decor,
      resume:             resume,
      brins:              brins.uniq,
      personnages:        personnages.uniq,
      data_paragraphes:   data_paragraphes,
      notes:              notes
    }
  end

  # Méthode pour ajouter des brins (identifiants) à la liste
  # des brins de la scène.
  def add_brins brs
    @brins += brs
  end

  def personnages_ids
    @personnages_ids ||= Array.new
  end

  def add_personnages prs
    @personnages += prs
  end

end #/Scene
end #/Film
end #/AnalyseBuild
