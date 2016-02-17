# encoding: UTF-8
class Cnarration
class Livre
  class << self

    # {StringHTML} Liste des livres au format HTML dans un UL
    def as_ul
      LIVRES.collect do |bid, bdata|
        (
          bdata[:hname].in_a(href:"livre/#{bid}/tdm?in=cnarration") +
          sous_titre_livre( bdata[:stitre])
        ).in_li

      end.join.in_ul(class:'tdm', id:'livres')
    end

    def sous_titre_livre sous_titre
      return "" if sous_titre.nil?
      "(#{sous_titre})".in_div(class:'stitre small italic')
    end
  end #/ << self
end #/Livre
end #/Cnarration
