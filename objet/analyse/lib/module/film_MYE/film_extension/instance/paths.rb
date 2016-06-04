# encoding: UTF-8
class FilmAnalyse
class Film

  def tdm_file
    @tdm_file ||= folder_in_films_mye + 'tdm.yaml'
  end

  def introduction_file
    @introduction_file ||= folder_in_films_mye + 'introduction.md'
  end

  # Le fichier timeline des scènes, s'il existe
  # Noter qu'il est chargé automatiquement s'il existe.
  def timeline_scenes_file
    @timeline_scenes_file ||= folder_in_films_mye + 'timeline_scenes.htm'
  end

  # {SuperFile} Path du dossier dans ./data/analyse/film_MYE
  def folder_in_films_mye
    @folder ||= FilmAnalyse::folder_films_MYE+film_id
  end

end # /Film
end # /FilmAnalyse
