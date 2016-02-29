# encoding: UTF-8
class FilmAnalyse
class Film

  include MethodesObjetsBdD

  attr_reader :id
  
  def initialize film_id
    @id = film_id
  end

  def table
    @table ||= FilmAnalyse::table_films
  end

end #/Film
end #/FilmAnalyse
