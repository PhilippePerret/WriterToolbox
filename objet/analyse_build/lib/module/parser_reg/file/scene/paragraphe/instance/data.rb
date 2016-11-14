# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe

  # Le texte seul du paragraphe
  attr_reader :texte

  # Toutes les données qui doivent être enregistrées dans le fichier
  # marshal.
  def all_data
    {
      texte:        texte,
      brins:        brins,
      personnages:  personnages,
      notes:        notes
    }
  end


end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
