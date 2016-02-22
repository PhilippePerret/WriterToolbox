# encoding: UTF-8
class Aide
  class << self

    def titre_h1 sous_titre = nil
      t = "Aide du site".in_h1
      t << onglets
      t << sous_titre.in_h2 unless sous_titre.nil?
      t
    end

    def onglets
      DATA_ONGLETS.collect do |route, titre|
        titre.in_a(href:route).in_li
      end.join.in_ul(class:'onglets')
    end

    def tdm
      (site.folder_objet+'aide/lib/data/tdm.rb').require
      DATA_TDM.collect do |route, ditem|
        if ditem[:titre]
          ditem[:hname].in_li(class:'titre')
        else
          ditem[:hname].in_a(href:route).in_li(class:'page')
        end
      end.join('').in_ul(class:'tdm')
    end

  end #/ << self
end #/Aide
