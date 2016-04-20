# encoding: UTF-8
class FilmAnalyse
class Travail

  include MethodesObjetsBdD


  attr_reader :id

  # Instanciation à l'aide d' l'ID du travail
  def initialize tid
    tid = nil if tid == 0
    @id = tid
  end


  def table
    @table ||= FilmAnalyse::table_travaux
  end

end #/Travail
end #/FilmAnalyse
