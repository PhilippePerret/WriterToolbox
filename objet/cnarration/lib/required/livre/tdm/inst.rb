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
        css = case dpage[:options][0] # pour savoir si c'est un titre etc.
        when '1' then 'page'
        when '2' then 'schap'
        when '3' then 'chap'
        else nil # page indéfinie
        end
        next if css.nil?
        dpage[:titre].in_li(class: css)
      end.join.in_ul(class: 'tdm tdm_livre')
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
