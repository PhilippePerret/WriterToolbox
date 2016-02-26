# encoding: UTF-8
class FilmAnalyse
class << self

  def folder_manuel
    @folder_manuel ||= site.folder_objet+"analyse/manuel"
  end


  # Dossier contenant les analyses des films TM (TextMate)
  # Voir aussi le dossier `folder_per_film` qui contient les
  # données par film.
  def folder_films
    @folder_analyses ||= begin
      d = site.folder_data+'analyse/films_tm'
      d.build unless d.exist?
      d
    end
  end

  # Dossier principal d'analyse qui contient les données des
  # films classées par film. Dossier initié pour contenir les
  # évènemenciers récupérés.
  def folder_per_film
    @folder_per_film ||= begin
      d = site.folder_data+'analyse/data_per_film'
      d.build unless d.exist?
      d
    end
  end

  def folder_modules
    @folder_modules ||= folder_lib+'module'
  end

  def folder_lib
    @folder_lib ||= folder+'lib'
  end
  def folder
    @folder ||= site.folder_objet+'analyse'
  end
end #/<<self
end #/FilmAnalyse
