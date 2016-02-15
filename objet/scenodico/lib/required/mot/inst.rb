# encoding: UTF-8
class Scenodico
class Mot

  include MethodesObjetsBdD

  attr_reader :id
  
  def initialize mot_id
    @id = mot_id
  end

end #/Mot
end #/Scenodico
