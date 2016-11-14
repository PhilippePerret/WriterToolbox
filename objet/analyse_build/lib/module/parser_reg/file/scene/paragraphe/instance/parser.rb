# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe

  require './objet/analyse_build/lib/module/parser_reg/_first/parse_relatifs_module.rb'
  include ModuleParseRelatifs

  # = main =
  #
  # Méthode principale qui parse un paragraphe quelconque de
  # la scène, c'est-à-dire n'importe quel paragraphe à part
  # la première ligne d'info.
  #
  # Un paragraphe est constitué d'un texte (qui peut contenir des
  # renvois à des notes), suivi d'une tabulation et de marques de
  # brins, de personnages, etc.
  #     <TEXTE> [TAB <MARQUES>]
  #
  def parse
    @texte, @liste_relatifs = code.strip.split("\t")
    parse_relatifs && add_elements_to_scene
      # Note : la méthode parse_relatifs se trouve dans le module
      # _first/parse_relatifs_module
  end


  # Méthode qui ajoute les éléments relevés à la scène du
  # paragraphe.
  #
  # Noter qu'on ne le fait que si des éléments ont été trouvés
  #
  def add_elements_to_scene
    brins.empty?        || scene.add_brins(brins)
    notes.empty?        || scene.add_notes(notes)
    personnages.empty?  || scene.add_personnages(personnages)
    scenes.empty?       || scene.add_scenes(scenes)
  end

end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
