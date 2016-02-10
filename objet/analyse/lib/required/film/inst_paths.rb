# encoding: UTF-8
class FilmAnalyse
class Film
  def html_file
    @html_file ||= FilmAnalyse::folder_films + "#{sym}.htm"
  end
end #/Film
end #/FilmAnalyse
