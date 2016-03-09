# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def give_balise_of_filmodico fref
    site.require_objet 'filmodico'
    # On récolte les films qui peuvent correspondre au titre original,
    # au titre en français ou au film-id
    res = Filmodico::table_films.select(where:"titre LIKE '%#{fref}%' OR titre_fr LIKE '%#{fref}%' OR film_id LIKE '%#{fref}%'", colonnes:[:film_id, :titre], nocase:true).values

    if res.empty?
      "Aucun film ne correspond à la référence #{fref}"
    else
      res = res.collect do |hfilm|
        lien_fiche = hfilm[:titre].in_a(href:"filmodico/#{hfilm[:id]}/show", target:'_new')
        "<input type='text' value='FILM[#{hfilm[:film_id]}]' /> (#{lien_fiche})"
      end.join('<br>') +
      '<script type="text/javascript>UI.auto_selection_text_fields()</script>"'
      sub_log res
      "Nombre de films trouvés : #{res.count}"
    end
  end

  def give_balise_of_scenodico mot_ref
    site.require_objet 'scenodico'
    res = Scenodico::table_mots.select(where:"mot LIKE '%#{mot_ref}%'", nocase: true, colonnes:[:mot]).values
    if res.empty?
      "Aucun mot n'a été trouvé correspondant à `#{mot_ref}`."
    else
      mess = res.collect do |hmot|
        "<input type='text' value='MOT[#{hmot[:id]}|#{hmot[:mot].downcase}]' />"
      end.join('<br>') + '<script type="text/javascript>UI.auto_selection_text_fields()</script>"'
      sub_log mess
      "Nombre de mots trouvés : #{res.count}"
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
