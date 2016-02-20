# encoding: UTF-8
class Cnarration
class Livre
  class << self

    # {StringHTML} Liste des livres au format HTML dans un UL
    def as_ul
      ibook = -1
      LIVRES.collect do |bid, bdata|
        ibook += 1
        style = "left:#{(ibook * 80) - 200}px"
        # break if (ibook += 1) > 1
        (
          tranche_livre(bdata).in_a(href:"livre/#{bid}/tdm?in=cnarration", title: sous_titre_livre(bdata[:stitre]))
        ).in_div(class:'book_droit', style:style)
      end.join.in_div(id:'book_list') +
      '<div style="clear:both"></div>'
    end

    def sous_titre_livre sous_titre
      return "" if sous_titre.nil?
      sous_titre
    end

    def tranche_livre bdata
      titre = bdata[:hname]
      (
        "Philippe Perret".in_span(class:'fright small') +
        bdata[:hname].in_span(class:'titre')
      )
    end

  end #/ << self
end #/Livre
end #/Cnarration
