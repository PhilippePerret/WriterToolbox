# encoding: UTF-8
class Scenodico
class Mot

  def as_lien
    @as_lien ||= mot.in_a(href:"scenodico/#{id}/show", class:'mot', target:'_new')
  end

  def formate str
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){
      tout    = $&
      mot_id  = $1.to_i
      mot_mot = $2.to_s
      mot_mot.in_a(href:"scenodico/#{mot_id}/show", class:'mot', target:'_mot_scenodico_')
    }
    return str
  end

  # Formate une liste de mots
  def formate_mots arr_ids
    return "---" if arr_ids.nil?
    arr_ids.collect do |mid|
      Scenodico::Mot::get(mid).as_lien
    end.join(' – ')
  end

  def definition_formated
    (formate definition)
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
    (categories||Array::new).collect do |cate_id|
      Scenodico::Categorie::get(cate_id).hname
    end.join(' – ')
  end
  def liens_formated
    return "---" if liens.nil?
    liens.collect do |lien|
      lien
    end.join(' – ')
  end
end #/Mot
end #/Scenodico
