# encoding: UTF-8
class ::Array
  def as_people_list as_acteur = false
    self.collect do |hpeople|
      pat = "#{hpeople[:prenom]} #{hpeople[:nom]}"
      pat += " (#{hpeople[:prenom_perso]} #{hpeople[:nom_perso]})" if as_acteur
      pat
    end.pretty_join
  end
  def as_actor_list
    self.collect do |hpeople|
      (
        "#{hpeople[:prenom]} #{hpeople[:nom]}".in_span(class:'actor') +
        "#{hpeople[:prenom_perso]} #{hpeople[:nom_perso]}".in_span(class:'perso')
      ).in_div(class:'actor')
    end.join
  end
end
class Filmodico

  def as_card
    (affiche.in_div(class:'affiche') +
    boutons_edition +
    titre.in_div(class:'titre') +
    ( titre_fr.nil? ? '' : titre_fr.in_div(class:'titre_fr') ) +
    resume.in_div(class:'resume') +
    div_infos +
    '<div style="clear:both"></div>' +
    div_people
    ).in_div(class:'film')
  end

  # L'image de l'affiche du film
  # Note : Pour le moment, on la prend sur le site de l'atelier Icare
  def affiche
    @affiche ||= "<img src='http://www.atelier-icare.net/img/affiches/#{film_id}.jpg' />"
  end

  def boutons_edition
    return "" unless user.admin?
    (
      "[Edit]".in_a(href:"filmodico/#{id}/edit")
    ).in_div(class:'tiny fright')
  end

  def span_lib_val lib, val
    (lib.in_span(class:'libelle') + val.in_span(class:'value')).in_span(class:'libval')
  end
  def div_lib_val lib, val
    (lib.in_span(class:'libelle') + val.in_span(class:'value')).in_div(class:'libval')
  end
  def div_people
    (
      div_lib_val("Réalisé par", hrealisateur) +
      div_lib_val("Produit par", hproducteurs) +
      div_lib_val("Écrit par", hauteurs) +
      hacteurs
    ).in_div(class:'people')
  end
  def div_infos
    (
      span_lib_val("Année", annee.to_s) +
      span_lib_val("Durée", duree.as_duree) +
      span_lib_val("Pays", hpays)
    ).in_div(class:'infos')
  end

  # Le ou les réalisateurs, au format humain
  def hrealisateur  ; realisateur.as_people_list    end
  def hproducteurs  ; producteurs.as_people_list    end
  def hauteurs      ; auteurs.as_people_list        end
  def hacteurs
    "Avec".in_span(class:'libelle').in_div +
    acteurs.as_actor_list
  end
  # Les pays du film, au format humain
  def hpays
    @hpays ||= begin
      pays.collect do |pa|
        PAYS[pa]
      end.pretty_join
    end
  end
end
