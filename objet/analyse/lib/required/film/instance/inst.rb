# encoding: UTF-8
class FilmAnalyse
class Film

  include MethodesMySQL

  attr_reader :id

  def initialize film_id
    @id = film_id
  end

  # Création du film s'il existe dans le Filmodico mais pas
  # dans les analyses.
  def create
    FilmAnalyse.require_module('film')
    proceed_create
  end

  def table
    @table ||= FilmAnalyse.table_films
  end

end #/Film
end #/FilmAnalyse
