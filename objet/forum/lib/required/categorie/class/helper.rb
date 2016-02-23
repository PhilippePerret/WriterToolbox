# encoding: UTF-8
class Forum
class Categorie
  class << self

    def values_for_select
      CATEGORIES.collect do |cate_sym, dcate|
        [dcate[:id], dcate[:hname]]
      end
    end
    
  end # / << self
end #/ Categorie
end #/ Forum
