# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # L'instance {Filmodico} du film de la scène
  attr_reader :film

  # Le code de la scène tel que défini dans le fichier
  attr_reader :code

  def initialize film, code
    @film   = film
    @code   = code
    @numero = self.class.numero_courant
    # On parse la scène dès son instanciation
    parse
  end

  # La première scène, qui contient les informations principales
  # de la scène
  def first_line
    @first_line ||= lines.shift
  end

  # Les paragraphes de la scène, mais en lignes brutes, avant
  # traitement. On les appelle alors des lignes.
  #
  # Noter que la première ligne, la ligne d'info, est retirée
  # de cette liste dès qu'on l'invoque.
  def lines
    @lines ||= code.strip.split("\n")
  end


end #/Scene
end #/Film
end #/AnalyseBuild
