# encoding: UTF-8
=begin

Surclassement des méthodes usuelles pour qu'elles retournent
un code Latex.

Noter que ces méthodes sont appelées, normalement, APRÈS le
traitement par Kramdown, donc elles doivent retourner un
code LaTex conforme.

=end
class ::String

  def formate_balises_mots
    str = self
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){
      mot_id = $1.to_i
      mot = $2.freeze
      "#{mot}\\index{#{mot}}"
    }
    str
  end

  def formate_balises_films
    str = self
    str.gsub!(/FILM\[(.*?)\]/){ traite_film $1.freeze }
    str.gsub!(/film:([a-zA-Z0-9]+)/){ traite_film $1.freeze }
    str
  end
  # TODO: Il faudrait directement les traiter autrement pour
  # qu'ils soient bien formaté, et gérer ici le fait qu'il
  # s'agit d'une première ou d'une autre apparition
  def traite_film film_id
    "\\film{#{film_id}}"
  end

  # Balises REF[...] qui vont référence à une autre page
  # Le contenu de la balise est l'ID de la page
  def formate_balises_references
    str = self
    str.gsub!(/REF\[(.*?)\]/){
      pid, ancre, titre = $1.split('|')
      if titre.nil? && ancre != nil
        titre = ancre
        ancre = nil
      end
      ipage = Cnarration::Page::get(pid.to_i)
      "\\ref{ipage.latex_ref} page \\pageref{ipage.latex_ref}"
    }
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

  # Surclassement de la méthode originale
  def formate_balises_colon balise
    str = self
    # Original:
    # str.gsub!(/#{balise}:\|(.*?)\|/, "<#{balise}>\\1</#{balise}>")
    # str.gsub!(/#{balise}:(.+?)\b/, "<#{balise}>\\1</#{balise}>")
    str.gsub!(/#{balise}:\|(.*?)\|/, "\\#{balise}{\\1}")
    str.gsub!(/#{balise}:(.+?)\b/, "\\#{balise}{\\1}")
    str
  end

end
