# encoding: UTF-8
class Unan
class Program
class Exemple

  # -> MYSQL UNAN
  include MethodesObjetsBdD

  # ID de l'exemple dans la table
  attr_reader :id

  def initialize eid = nil
    eid = nil if eid == 0
    @id = eid
  end


  def table
    # -> MYSQL UNAN
    @table ||= Unan::table_exemples
  end

end #/Exemple
end #/Program
end #/Unan
