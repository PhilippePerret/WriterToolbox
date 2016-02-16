# encoding: UTF-8
class Scenodico
class Categorie

  def hname     ; @hname ||= get(:hname) end


  def table
    @table ||= Scenodico::table_categories
  end
  
end #/Categorie
end #/Scenodico
