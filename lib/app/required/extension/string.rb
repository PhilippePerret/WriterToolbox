# encoding: UTF-8
class ::String

  def formate_balises_propres
    str = self

    debug "STRING AVANT = #{str.gsub(/</,'&lt;').inspect}"

    str = str.formate_balises_references
    str = str.formate_balises_mots
    str = str.formate_balises_films
    str = str.formate_balises_livres
    str = str.formate_balises_personnages
    str = str.formate_balises_realisateurs
    str = str.formate_balises_producteurs
    str = str.formate_balises_acteurs
    str = str.formate_balises_auteurs
    str = str.formate_termes_techniques

      debug "STRING APRÈS = #{str.gsub(/</,'&lt;').inspect}"
    return str
  end

  def formate_balises_references
    str = self
    str.gsub!(/REF\[(.*?)\]/){
      pid, ancre, titre = $1.split('|')
      if titre.nil? && ancre != nil
        titre = ancre
        ancre = nil
      end
      lien.cnarration(to: :page, from_book:$narration_book_id, id: pid.to_i, ancre:ancre, titre:titre)
    }
    str
  end

  def formate_balises_mots
    str = self
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){ lien.mot($1.to_i, $2.to_s) }
    str
  end

  def formate_balises_films
    str = self
    str.gsub!(/FILM\[(.*?)\]/){ lien.film($1.to_s) }
    str
  end

  def formate_balises_livres
    str = self
    str.gsub!(/LIVRE\[(.*?)\]/){
      ref, titre = $1.split('|')
      lien.livre(titre, ref)
    }
    str.formate_balises_colon('livre')
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
    str.gsub!(/#{balise}:(.+?)\b/, "<#{balise}>\\1</#{balise}>")
    str
  end

end #/String
