# encoding: UTF-8
=begin
Extension de FilmAnalyse pour l'affichage de la liste des films analysés
=end
class FilmAnalyse
class << self

  def analyses_as_ul
    "[LISTE DES ANALYSES]"
  end

  def liste_analyses_autorized

  end

  def liste_analyses_non_autorized
    "Film non autorisés".in_h3
  end

end # << self
end #/FilmAnalyse
