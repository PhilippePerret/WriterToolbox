# encoding: UTF-8
class Scenodico
class Categorie

  include MethodesMySQL

  attr_reader :cate_ref
  attr_reader :cate_id
  attr_reader :id

  def initialize cate_ref
    @cate_ref = cate_ref
    case cate_ref
    when String then init_with_cate_id
    when Fixnum then init_with_id
    else raise "Impossible d'initialiser une catégorie avec un #{cate_ref.class}"
    end
  end

  def init_with_cate_id
    @cate_id = cate_ref
    @id = table.select(where:{cate_id: cate_ref}, colonnes:[]).first[:id]
  end

  def init_with_id
    @id = cate_ref
  end

end #/Categorie
end #/Scenodico
