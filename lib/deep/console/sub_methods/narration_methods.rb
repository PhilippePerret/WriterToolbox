# encoding: UTF-8
class SiteHtml
class Admin
class Console


  # Affiche (dans sub_log) les pages de la collection narration
  # qui sont des pages et dont le niveau de développement est
  # +nivdev+, de "1" à "a" en passant par "9"
  def liste_pages_narration_of_niveau nivdev
    site.require_objet 'cnarration'
    Cnarration::require_module 'cnarration' # par Cnarration::pages
    niveau_humain = Cnarration::NIVEAUX_DEVELOPPEMENT[nivdev.to_i][:hname]
    sub_log "Pages narration de niveau de développement #{nivdev} : #{niveau_humain}".in_h3
    sub_log Cnarration::pages_as_ul(where:"options LIKE '1#{nivdev}%'")
    return "" # pour ne rien afficher dans la console sous la ligne
  end

  def goto_nouvelle_page_narration
    redirect_to 'page/edit?in=cnarration'
    ""
  end

end #/Console
end #/Admin
end #/SiteHtml
