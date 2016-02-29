# encoding: UTF-8
class FilmAnalyse
class Film
  def name
    @name ||= "#{sym}.htm"
  end
  def html_file
    @html_file ||= FilmAnalyse::folder_films + name
  end
end #/Film
end #/FilmAnalyse
