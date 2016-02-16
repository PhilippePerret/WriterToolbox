# encoding: UTF-8
class Scenodico
class Categorie
  class << self

    # On peut instancier la catégorie soit avec l'identifiant
    # fixnum soit avec le `cate_id` en string
    def get cat_id
      cat_id = cat_id.to_s
      @instances ||= Hash::new
      @instances[cat_id] ||= new(cat_id)
    end

    def values_for_select
      @values_for_select ||= begin
        menus = [['', "Choisir catégorie…"]]
        menus += Scenodico::table_categories.select(order: "hname ASC", colonnes:[:cate_id, :hname]).values.collect do |hcate|
          [hcate[:cate_id], hcate[:hname]]
        end
        menus
      end
    end
  end #/<< self
end #/Categorie
end #/Scenodico
