# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Retourne la balise pour le film de référence
  # +fref+ qui peut être une portion seulement du film
  def give_balise_of_filmodico fref
    site.require_objet 'filmodico'
    # On récolte les films qui peuvent correspondre au titre original,
    # au titre en français ou au film-id
    res = Filmodico::table_films.select(where:"titre LIKE '%#{fref}%' OR titre_fr LIKE '%#{fref}%' OR film_id LIKE '%#{fref}%'", colonnes:[:film_id, :titre], nocase:true).values

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
