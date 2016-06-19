# encoding: UTF-8
class Scenodico
class Mot

  include MethodesMySQL

  attr_reader :id

  def initialize mot_id = nil
    @id = mot_id
  end

end #/Mot
end #/Scenodico
