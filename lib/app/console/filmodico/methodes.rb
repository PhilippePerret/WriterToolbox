# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Retourne une liste de Hash de données des films qui
  # correspondent à la référence +fref+ qui peut être une
  # portion du titre original/français ou de l'identifiant
  # type Harvard du film
  def get_all_films_of_ref fref
    site.require_objet 'filmodico'
    Filmodico::table_films.select(where:"titre LIKE '%#{fref}%' OR titre_fr LIKE '%#{fref}%' OR film_id LIKE '%#{fref}%'", colonnes:[:film_id, :titre], nocase:true).values
  end

  # Retourne la balise pour le film de référence
  # +fref+ qui peut être une portion seulement du film
  def give_balise_of_filmodico fref
    # On récolte les films qui peuvent correspondre au titre original,
    # au titre en français ou au film-id
    res = get_all_films_of_ref fref

    if res.empty?
      [nil, "Aucun film ne correspond à la référence #{fref}"]
    else
       balises = res.collect do |hfilm|
        lien_fiche = hfilm[:titre].in_a(href:"filmodico/#{hfilm[:id]}/show", target:'_blank')
        {value: "FILM[#{hfilm[:film_id]}]", after: " (#{lien_fiche})"}
      end
      [balises, "Nombre de films trouvés : #{balises.count}"]
    end
  end
end #/Console
end #/Admin
end #/SiteHtml
