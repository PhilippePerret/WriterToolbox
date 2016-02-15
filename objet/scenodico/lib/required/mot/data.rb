# encoding: UTF-8
class Scenodico
class Mot

  def mot; @mot ||= get(:mot) end


  def table ; @table ||= Scenodico::table_mots end
end #/Mot
end #/Scenodico
