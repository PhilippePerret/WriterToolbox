# encoding: UTF-8
class ::String

  def formate_balises_propres
    debug "STRING DANS FORMATE BALISES PROPRES : #{self.inspect}"
    str = self.formate_balises_mots
    str = str.formate_balises_films
    str = str.formate_balises_livres
    str = str.formate_balises_personnages
    str = str.formate_balises_realisateurs
    str = str.formate_balises_producteurs
    str = str.formate_balises_acteurs
    str = str.formate_balises_auteurs
    str = str.formate_termes_techniques
    return str
  end

  def formate_balises_mots
    str = self
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){ lien.mot($1.to_i, $2.to_s) }
    str
  end

  def formate_balises_films
    str = self
    str.gsub!(/FILM\[(.*?)\]/){ lien.film($1.to_s) }
    str.gsub!(/film:([a-zA-Z0-9]+)/){ lien.film($1.to_s) }
    str
  end

  def formate_balises_livres
    self.formate_balises_colon('livre')
  end

  def formate_balises_personnages
    self.formate_balises_colon('personnage')
  end

  def formate_balises_acteurs
    self.formate_balises_colon('acteur')
  end

  def formate_balises_realisateurs
    self.formate_balises_colon('realisateur')
  end

  def formate_balises_producteurs
    self.formate_balises_colon('producteur')
  end

  def formate_balises_auteurs
    self.formate_balises_colon('auteur')
  end

  def formate_termes_techniques
    self.formate_balises_colon('tt')
  end

  def formate_balises_colon balise
    str = self
    str.gsub!(/#{balise}:\|(.*?)\|/, "<#{balise}>\\1</#{balise}>")
    str.gsub!(/#{balise}:(.*?)([\.…  ,\)])/, "<#{balise}>\\1</#{balise}>\\2")
    str
  end

end #/String
