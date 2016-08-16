# encoding: UTF-8
class Citation

  def output
    (
      div_citation    +
      div_auteur      +
      div_source_humaine +
      boutons_edition +
      description_if_any
    ).in_div(class: 'citation', itemtype: 'CreativeWork')
  rescue Exception => e
    debug "# IMPOSSIBLE D'AFFICHER LA CITATION ##{id} : #{e.message}"
    debug e
    'Malheureusement, il est impossible d’afficher cette citation.'.in_div(class: 'big air')
  end

  def div_citation
    citation.in_div(class: 'big air', itemprop: 'citation')
  end
  def div_auteur
    auteur.in_div(class: 'right italic', itemtype: 'Person', itemprop: 'author')
  end
  def div_source_humaine
    s = source_humaine
    debug "source : #{source}"
    s.sub!(/([0-9]{4,4})/){ "<span itemprop=\"datePublished\">#{$1}</span>"}
    return s
  end

end #/Citation
