# encoding: UTF-8
class UnanAdmin
class PageCours
  
  include MethodesObjetsBdD

  # {Fixnum} Identifiant de la page de cours éditée
  attr_reader :id
  def initialize pid
    @id = pid
  end

end #/PageCours
end #/UnanAdmin
