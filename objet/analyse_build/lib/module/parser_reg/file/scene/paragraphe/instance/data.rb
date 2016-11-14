# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe

  # Le texte seul du paragraphe
  attr_reader :texte

  # {Array} La liste des identifiants de brins du paragraphe
  attr_reader :brins

  # {Array} La liste des identifiants des personnages du paragraphe
  attr_reader :personnages

  # {Array} La liste des identifiants des NOTES du paragraphe
  attr_reader :notes

  # {Array} La liste des numéros de SCENES liées au paragraphe
  # Note : la scène contenant le paragraphe ne se trouve pas dans
  # cette liste.
  attr_reader :scenes

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
