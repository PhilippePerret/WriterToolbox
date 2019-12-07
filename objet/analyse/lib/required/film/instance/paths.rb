# encoding: UTF-8
class FilmAnalyse
class Film

  def folder_mye
    @folder_mye ||= FilmAnalyse.folder_films_MYE + film_id
  end
  def html_mye_file
    @html_mye_file ||= folder_mye + "whole.html"
  end

  def name
    @name ||= "#{sym}.htm"
  end
  def html_file
    @html_file ||= FilmAnalyse.folder_films + name
  end
end #/Film
end #/FilmAnalyse
