# encoding: UTF-8
class FilmAnalyse
class Film

  def tdm_file
    @tdm_file ||= folder_in_films_mye + 'tdm.yaml'
  end

  def introduction_file
    @introduction_file ||= folder_in_films_mye + 'introduction.md'
  end

  # {SuperFile} Path du dossier dans ./data/analyse/film_MYE
  def folder_in_films_mye
    @folder ||= FilmAnalyse::folder_films_MYE+film_id
  end

end # /Film
end # /FilmAnalyse
