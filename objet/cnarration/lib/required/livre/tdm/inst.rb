# encoding: UTF-8
class Cnarration
class Livre
class Tdm

  include MethodesMySQL

  # {Fixnum} Identifiant de la table des matières
  # Note : Est égal à l'identifiant du livre
  attr_reader :id

  # {Cnarration::Livre} Instance du livre de la table des matières
  attr_reader :livre

  def initialize livre
    @livre  = livre
    @id     = livre.id # correspond à l'id du livre
  end

  GREEN_BALL  =  ' <img src="view/img/divers/rond-vert.png" style="width:10px" />'
  ORANGE_BALL =  ' <img src="view/img/divers/rond-orange.png" style="width:10px" />'
  # {StringHTML} La table des matières comme une liste UL
  #
  # C'est la méthode qui est appelée quand on se rend sur
  # la table des matières du livre.
  def as_ul
    if get_all.nil?
      "Pas de table des matières pour le moment."
    else
      pages_ids.collect do |page_id|
        dpage = pages[page_id]
        ispage = dpage[:options][0].to_i == 1
        nivdev = dpage[:options][1].to_i(11)
        # debug "Niveau de développement page ##{page_id} : #{nivdev}"
        titre = dpage[:titre]
        # Une page de la collection
        if ispage
          mark_dev_insuffisant =
            if nivdev < 4
              ''
            elsif nivdev < 8
              ORANGE_BALL
            else
              GREEN_BALL
            end
          titre = (
            titre + mark_dev_insuffisant
            ).in_a(class: (nivdev < 8 ? 'discret' : ''), href:"page/#{page_id}/show?in=cnarration", title:"Page ##{page_id}")
        elsif user.admin?
          titre = titre.in_a(href:"page/#{page_id}/edit?in=cnarration", title:"Titre ##{page_id}")
        end
        titre.in_li(class: "niv#{dpage[:options][0]}")
      end.join.in_ul(class: 'tdm livre_tdm')
    end
  end

  # {Hash} des pages du livre de cette table des matières, avec en clé
  # l'identifiant de la page et en valeur un Hash ne contenant que :
  #   {:titre, :id, :options, :handler}
  def pages
    @pages ||= begin
      drequest = {
        where:    {livre_id: id},
        colonnes: [:titre, :handler, :options]
      }
      hpages = {}
      Cnarration::table_pages.select(drequest).each do |dpage|
        hpages.merge! dpage[:id] => dpage
      end
      hpages
    end
  end

  def pages_ids
    @pages_ids ||= Cnarration::Livre.ids_tdm_of_livre(id)
  end

  def table
    @table ||= Cnarration.table_tdms
  end
end #/Tdm
end #/Livre
end #/Cnarration
