# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # Identifiant de la scène (donc son numéro)
  # Il est attribué à l'instanciation.
  # Noter qu'il peut y avoir une erreur si le temps de la scène
  # ne correspond pas à la scène suivante.
  attr_reader :numero

  # Données de la première ligne, décomposées
  attr_reader :horloge
  attr_reader :time
  attr_reader :effet
  attr_reader :lieu
  attr_reader :decor
  attr_reader :resume

  attr_reader :data_paragraphes
  attr_reader :data_notes


end #/Scene
end #/Film
end #/AnalyseBuild
