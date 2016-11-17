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
  # Note : on n'ajoute plus les relatifs à la scène. Par exemple, si le
  # paragraphe est associé à un brin, on n'ajoute plus ce brin à la scène,
  # sinon, tous les paragraphes de la scène se retrouveraient associés au
  # brin.
  # 
  def parse
    @texte, @liste_relatifs = code.strip.split("\t")
    parse_relatifs
      # Note : la méthode parse_relatifs se trouve dans le module
      # _first/parse_relatifs_module
  end

end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
