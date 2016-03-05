class SiteHtml
class Admin
class Console

  def give_balise_of_filmodico fref
    site.require_objet 'filmodico'
    # On récolte les films qui peuvent correspondre au titre original,
    # au titre en français ou au film-id
    res = Filmodico::table_films.select(where:"titre LIKE '%#{fref}%' OR titre_fr LIKE '%#{fref}%' OR film_id LIKE '%#{fref}%'", colonnes:[:film_id, :titre], nocase:true).values

    sub_log (
      res.collect do |hfilm|
        "<input type='text' value='FILM[#{hfilm[:film_id]}]' /> (#{hfilm[:titre]})"
      end.join('<br>') +
      '<script type="text/javascript>UI.auto_selection_text_fields()</script>"'
    )

    if res.empty?
      "Aucun film ne correspond à la référence #{fref}"
    else
      "Nombre de films trouvés : #{res.count}"
    end
  end

  def give_balise_of_scenodico mot_ref
    site.require_objet 'scenodico'
    res = Scenodico::table_mots.select(where:"mot LIKE '%#{mot_ref}%'", nocase: true, colonnes:[:mot]).values
    mess = res.collect do |hmot|
      "<input type='text' value='MOT[#{hmot[:id]}|#{hmot[:mot].downcase}]' />"
    end.join('<br>')+
      '<script type="text/javascript>UI.auto_selection_text_fields()</script>"'
    sub_log mess
    if res.empty?
      "Aucun mot n'a été trouvé correspondant à `#{mot_ref}`."
    else
      "Nombre de mots trouvés : #{res.count}"
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
