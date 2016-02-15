# encoding: UTF-8
class Scenodico
  class << self

    # Affichage des mots du scénodico dans un ul
    # {StringHTML}
    def as_ul
      list(as: :data, colonnes:[:mot]).collect do |hmot|
        "#{hmot[:mot]}".in_a(href:"scenodico/#{hmot[:id]}/show").in_li(class:'mot')
      end.join.in_ul(id:'scenodico')
    end

  end # /<< self
end # Scenodico
