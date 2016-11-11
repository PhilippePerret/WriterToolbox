# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # L'instance Filmodico du film de la scène
  attr_reader :film

  # Le code de la scène tel que défini dans le fichier
  attr_reader :code

  def initialize film, code
    @film = film
    @code = code
  end

  # La première scène, qui contient les informations principales
  # de la scène
  def first_line
    @first_line ||= lines[0]
  end

  # Les lignes de la scène
  def lines
    @lines ||= code.strip.split("\n")
  end


end #/Scene
end #/Film
end #/AnalyseBuild
