# encoding: UTF-8
class Cnarration
class Search
class SFile

  # {Cnarration::Search} Instance de la recherche
  attr_reader :search


  # Identifiant de la page
  attr_reader   :page_id
  attr_accessor :page_titre
  attr_accessor :livre_id
  attr_accessor :relative_path

  attr_accessor :occurrences
  attr_accessor :weight
  attr_accessor :founds_in_textes
  attr_accessor :founds_in_titres

  # L'instanciation d'une recherche se fait avec
  # le texte brut trouvé
  def initialize search, page_id
    @search   = search
    @page_id  = page_id
    @occurrences      = 0
    @founds_in_titres = Array::new
    @founds_in_textes = Array::new
    @weight           = 0
  end

  # = main =
  #
  # Méthode qui construit le texte à écrire pour rendre
  # compte des valeurs trouvées dans le fichier courant
  def output
    (
      full_titre_linked_to_file +
      occurrences_et_poids +
      (
        occurrences_in_titres +
        occurrences_in_textes
      ).in_div(class:'founds')
    ).in_div(class:'file')
  end

  def occurrences_et_poids
    "<span class='ocs'>#{occurrences} occurrence#{occurrences > 1 ? 's' : ''}</span> <span class='poids'>(poids : #{weight})</span>".in_div(class:'divoc')
  end

  # Retourne la valeur de poids d'une itération du mot.
  # Par défaut, il vaut 1, mais si le titre de la page
  # contient le texte recherché (min/maj) ce poids passe
  # à 3. Et si le titre du livre contient aussi la
  # recherche, ça passe à 5
  def poids_iteration
    @poids_iteration ||= begin
      pds = 1
      pds += 2 if titre_contient_searched?
      pds += 2 if titre_livre_contient_searched?
      pds
    end
  end

  # Retourne true si le titre de la page contient la
  # recherche, en minuscule ou en majuscule.
  def titre_contient_searched?
    @titre_contient_searched ||= begin
      if occurrences > 0 # <= traité par les titres
        true
      else
        page_titre.match(search.searched) != nil
      end
    end
  end

  def titre_livre_contient_searched?
    @titre_livre_contient_searched ||= begin
      # On enregistre provisoirement la valeur dans le Hash des
      # données des livres pour ne pas avoir à la recalculer pour
      # chaque page.
      unless ::Cnarration::LIVRES[livre_id].has_key?(:contient_search)
        ::Cnarration::LIVRES[livre_id].merge!( contient_search: (livre_titre.match(search.searched) != nil))
      end
      ::Cnarration::LIVRES[livre_id][:contient_search]
    end
  end


  def occurrences_in_textes
    return "" if founds_in_textes.count == 0
    founds_in_textes.collect { |ifound| ifound.output(true) }.join("<br>")
  end
  def occurrences_in_titres
    return "" if founds_in_titres.count == 0
    founds_in_titres.collect { |ifound| ifound.output(false) }.join('<br>')
  end

  def full_titre_linked_to_file
    @full_titre_linked_to_file ||= begin
      titre_complet.in_a(href:"page/#{page_id}/show?in=cnarration").in_div(class:'titre')
    end
  end
  def titre_complet
    @titre_complet ||= begin
      (livre_titre.in_span(class:'fright italic small') + page_titre)
    end
  end
  def livre_titre
    @livre_titre ||= ::Cnarration::LIVRES[livre_id][:hname]
  end

end #/GFile
end #/Search
end #/Cnarration
