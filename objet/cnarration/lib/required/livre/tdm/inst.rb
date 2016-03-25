# encoding: UTF-8
class Cnarration
class Livre
class Tdm

  include MethodesObjetsBdD

  # {Fixnum} Identifiant de la table des matières
  # Note : Est égal à l'identifiant du livre
  attr_reader :id

  # {Cnarration::Livre} Instance du livre de la table des matières
  attr_reader :livre

  def initialize livre
    @livre  = livre
    @id     = livre.id # correspond à l'id du livre
  end

  # {StringHTML} La table des matières comme une liste UL
  def as_ul
    if data.nil?
      "Pas de table des matières pour le moment."
    else
      pages_ids.collect do |page_id|
        dpage = pages[page_id]
        debug "dpage: #{dpage.inspect}"
        next if dpage.nil?
        titre = dpage[:titre]
        # Une page de la collection
        if dpage[:options][0] == "1"
          titre = titre.in_a(href:"page/#{page_id}/show?in=cnarration", title:"Page ##{page_id}")
        elsif user.admin?
          titre = titre.in_a(href:"page/#{page_id}/edit?in=cnarration", title:"Titre ##{page_id}")
        end
        titre.in_li(class: "niv#{dpage[:options][0]}")
      end.join.in_ul(class: 'tdm livre_tdm')
    end
  end

  # {Hash} des pages du livre de cette table des matières, avec en clé
  # l'identifiant de la page et en valeur un Hash ne contenant que :
  #   {:titre, :id, :options}
  def pages
    @pages ||= Cnarration::table_pages.select(where:"livre_id = #{id}", colonnes:[:titre, :options])
  end

  def pages_ids
    @pages_ids ||= get(:tdm)
  end

  def table
    @table ||= Cnarration::table_tdms
  end
end #/Tdm
end #/Livre
end #/Cnarration
