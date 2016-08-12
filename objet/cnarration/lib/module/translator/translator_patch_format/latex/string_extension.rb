# encoding: UTF-8
=begin

Surclassement des méthodes usuelles pour qu'elles retournent
un code Latex.

Noter que ces méthodes sont appelées, normalement, APRÈS le
traitement par Kramdown, donc elles doivent retourner un
code LaTex conforme.

=end
class ::String

  def as_latex
    str = self.gsub(/ /,'~{}')
    str.gsub!(/\&/, '\\\\&')
    str
  end
  alias :to_latex :as_latex

  def formate_balises_mots
    str = self
    str.gsub!(/MOT\[([0-9]+)\|(.*?)\]/){
      mot_id  = $1.to_i
      mot     = $2
      # Le mot indexé ne doit pas comporter d'accent ni de
      # caractères spéciaux
      mot_indexed = mot.normalized
      mot_indexed = if mot == mot_indexed
        mot
      else
        "#{mot_indexed}@#{mot}"
      end
      "#{mot}\\index{#{mot_indexed}}"
    }
    str
  end

  # Table pour tenir à jour les citations de films
  # Notamment, elle permettra de savoir combien chaque film a
  # été cité


  def formate_balises_films
    @films_citations ||= Hash.new
    str = self
    str.gsub!(/FILM\[(.*?)\]/){ traite_film $1.freeze }
    str.gsub!(/film:([a-zA-Z0-9]+)/){ traite_film $1.freeze }
    str
  end
  def traite_film film_id
    Narration::Film::titre_for_film film_id
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
    str.gsub!(/#{balise}:\|(.*?)\|/, "\\#{balise}{\\1}")
    str.gsub!(/#{balise}:(.+?)\b/, "\\#{balise}{\\1}")
    str
  end

end
