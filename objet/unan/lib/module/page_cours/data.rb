# encoding: UTF-8
class Unan
class Program
class PageCours

  include MethodesObjetsBdD

  # ID de la page de cours
  attr_reader :id

  def initialize pid
    @id = pid
  end


  def table
    @table ||= Unan::Program::PageCours::table_pages_cours
  end

end #/PageCours
end #/Program
end #/Unan
