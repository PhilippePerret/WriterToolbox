# encoding: UTF-8
class FilmAnalyse
class Film

  include MethodesObjetsBdD

  def table
    @table ||= FilmAnalyse::table_films
  end
  
end #/Film
end #/FilmAnalyse
