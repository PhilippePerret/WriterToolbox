# encoding: UTF-8
class FilmAnalyse
class Film

  def tdm_file
    @tdm_file ||= folder_in_archives + 'tdm.yaml'
  end

  # {SuperFile} Path du dossier dans ./data/analyse/data_per_film
  def folder_in_archives
    @folder ||= FilmAnalyse::folder_per_film+film_id
  end

end # /Film
end # /FilmAnalyse
