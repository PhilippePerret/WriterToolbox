# encoding: UTF-8
class FilmAnalyse
class Travail

  include MethodesObjetsBdD


  attr_reader :id

  # Instanciation à l'aide d' l'ID du travail
  def initialize tid
    @id = tid
  end


  def table
    @table ||= FilmAnalyse::table_travaux
  end
  
end #/Travail
end #/FilmAnalyse
