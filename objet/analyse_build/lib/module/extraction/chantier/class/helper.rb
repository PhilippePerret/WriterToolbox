# encoding: UTF-8
class AnalyseBuild
class << self

  # = main =
  #
  # Sortie lorsqu'un film a été choisi dans la liste des films, pour
  # procéder à une extraction de données.
  #
  def output_when_film_chantier
    current.film.titre.in_h3
  end


end #/<< self
end #/AnalyseBuild
