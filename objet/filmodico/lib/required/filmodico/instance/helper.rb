# encoding: UTF-8
class ::Array
  def as_people_list as_acteur = false, itemprop = nil
    self.collect do |hpeople|
      pat = "#{hpeople[:prenom]} #{hpeople[:nom]}".in_span(itemprop: 'name').in_span(itemtype: 'Person', itemprop: itemprop)
      pat += " (#{hpeople[:prenom_perso]} #{hpeople[:nom_perso]})" if as_acteur
      pat
    end.pretty_join
  end
  def as_actor_list
    self.collect do |hpeople|
      (
        "#{hpeople[:prenom]} #{hpeople[:nom]}".in_span(itemprop: 'name').in_span(itemtype: 'Person', itemprop: 'actor', class:'actor') +
        "#{hpeople[:prenom_perso]} #{hpeople[:nom_perso]}".in_span(class:'perso')
      ).in_div(class:'actor')
    end.join
  end
end
class Filmodico

  # = main =
  #
  # Méthode principale pour obtenir la carte/fiche du film.
  #
  # +with_css+ Si true, la méthode charge aussi le fichier show.css
  # qui permet d'obtenir les styles utiles pour le bon affichage de
  # la carte.
  #
  def as_card with_css = false
    if with_css
      page.add_css (Filmodico::folder + 'show.css')
    end
    (affiche.in_div(class:'affiche') +
    boutons_edition +
    titre.force_encoding('utf-8').in_div(class:'titre', itemprop: 'name') +
    ( titre_fr.nil? ? '' : titre_fr.in_div(class:'titre_fr') ) +
    resume.formate_balises_propres.to_html.in_div(class:'resume', itemprop: 'description') +
    div_infos +
    '<div style="clear:both"></div>' +
    div_people
    ).in_div(itemscope: true, itemtype: 'Movie', class:'film')
  end

  # L'image de l'affiche du film
  # Note : Pour le moment, on la prend sur le site de l'atelier Icare
  def affiche
    @affiche ||= "<img itemprop='image' src='./view/img/affiches/#{film_id}.jpg' />"
  end

  def boutons_edition
    return "" unless user.admin?
    (
      "[Edit]".in_a(href:"filmodico/#{id}/edit")
    ).in_div(class:'tiny fright')
  end

  def span_lib_val lib, val, itemprop = nil
    (lib.in_span(class:'libelle') + val.in_span(itemprop: itemprop, class:'value')).in_span(class:'libval')
  end
  def div_lib_val lib, val, itemprop = nil
    (lib.in_span(class:'libelle') + val.in_span(itemprop: itemprop, class:'value')).in_div(class:'libval')
  end
  def div_people
    (
      div_lib_val('Réalisé par',  hrealisateur) +
      div_lib_val('Produit par',  hproducteurs) +
      div_lib_val('Écrit par',    hauteurs)     +
      div_lib_val('Musique',      hcomposers)   +
                                  hacteurs
    ).in_div(class:'people')
  end
  def div_infos
    dur8601 = duree.as_iso_8601
    dureeh = "<time itemprop='duration' datetime='#{dur8601}'>#{duree.as_duree}</time>"
    (
      span_lib_val( "Année", annee.to_s.in_span(itemprop: 'datePublished') ) +
      span_lib_val( "Durée", dureeh )     +
      span_lib_val( "Pays", hpays )
    ).in_div(class:'infos')
  end

  # Le ou les réalisateurs, au format humain
  def hrealisateur  ; realisateur.as_people_list(false, 'director') end
  def hproducteurs  ; producteurs.as_people_list(false, 'producer') end
  def hauteurs      ; auteurs.as_people_list(false, 'author')       end
  def hcomposers    ; musique.as_people_list(false, 'musicBy')      end
  def hacteurs
    "Avec".in_span(class:'libelle').in_div +
    acteurs.as_actor_list
  end
  # Les pays du film, au format humain
  def hpays
    @hpays ||= pays.collect { |pa| PAYS[pa].in_span(itemprop: 'contentLocation') }.pretty_join
  end
end
