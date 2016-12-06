# encoding: UTF-8
class Scenodico
class Mot

  def as_lien
    @as_lien ||= mot.in_a(href:"scenodico/#{id}/show", class:'mot', target:'_blank')
  end

  def formate str
    return '' if str.nil?
    site.require_module 'kramdown'
    str = str.purified
    str = str.formate_balises_propres

    # Je ne transforme pas avec kramdown parce que tous les paragraphes
    # qui commencerait pas `<mot>:` serait considérés comme des paragraphes
    # stylés pas `<mot>`
    # str = str.kramdown
    
    str = str.split("\n").collect{|p| p.in_p}.join
    return str
  end

  # Formate une liste de mots
  def formate_mots arr_ids
    return nil if arr_ids.nil?
    arr_ids.collect do |mid|
      Scenodico::Mot::get(mid).as_lien
    end.join(' – ')
  end

  def definition_formated
    ( formate definition ).deserb
  end

  def relatifs_formated
    ( formate_mots relatifs )
  end
  def contraires_formated
    ( formate_mots contraires )
  end
  def synonymes_formated
    ( formate_mots synonymes )
  end

  def hcategories
    categories.collect do |cate_id|
      Scenodico::Categorie::get(cate_id).hname
    end.join(' – ')
  end

  def liens_formated
    return nil if liens.nil?
    get(:liens).force_encoding('utf-8').split("\n").collect do |lien|
      href, titre = lien.split('::')
      titre ||= href
      titre.in_a(href: href, target: :new)
    end.join('<br>')
  end
end #/Mot
end #/Scenodico
