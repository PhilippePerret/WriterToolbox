# encoding: UTF-8

page.title = "Analyses de films"

def film; @film ||= FilmAnalyse::Film.current end

class FilmAnalyse
# Spécialement pour l'affichage de cette page
class Show
class << self

  # = main =
  #
  # Sortie du code de la page à afficher
  def output
    titre_page =
      if film.analyse_tm? && !film.analyse_mye?
        ''
      else
        FilmAnalyse.titre_h1( film.titre, {onglets_top: true} )
      end

    titre_page +
    if !film.exist?
      message_film_doesnt_exist
    elsif !film.consultable?
      (titre_page == '' ? FilmAnalyse.titre_h1( film.titre, {onglets_top: true} ) : '') +
      message_film_non_consultable_par_user +
      fiche_film
    elsif film.analyse_tm? && !film.analyse_mye?
      # === ANALYSE DE TYPE TM ===
      FilmAnalyse.titre_h1( film.titre, {onglets_top: true} ) +
      output_as_analyse_tm
    elsif film.analyse_mye? && !film.analyse_tm?
      # === ANALYSE SEULEMENT MYE ===
      fiche_film +
      output_as_analyse_mye
    else
      # === ANALYSE MIXTE (*) ===
      # (*) c'est-à-dire une analyse qui comporte des fichiers MYE et
      # une analyse TM. Dans ce cas, on affiche :
      #   - un texte indiquant la mixité de l'analyse
      #   - la fiche du film
      #   - un lien pour voir l'analyse TM dans une autre fenêtre
      #   - les fichiers de l'analyse MYE
      warning_analyse_mixte   +
      fiche_film              +
      lien_open_analyse_tm    +
      output_as_analyse_mye
    end
  end

  # L'alerte placée au-dessus d'une analyse "mixte" c'est-à-dire avec
  # un fichier TM et des fichiers MYE.
  def warning_analyse_mixte
    'Analyse “mixte” contenant le fichier complexe d’analyse TM à ouvrir dans une nouvelle fenêtre (cf. le lien ci-dessous) ainsi que les fichiers d’analyse MYE sur cette page.'.in_p(class: 'small')
  end

  # Le lien pour ouvrir l'analyse TM lorsqu'il s'agit d'une analyse
  # "mixte", avec fichier TM et fichiers MYE.
  def lien_open_analyse_tm
    "Ouvrir l'analyse TM du film <strong>#{film.titre}</strong>".in_a(href: film.html_file.to_s, target: :new, class: 'cadre').in_p(class: 'air center')
  end

  # Retourne le code HTML de la fiche du film pour
  def fiche_film
    site.require_objet 'filmodico'
    Filmodico.get(film.id).as_card(css = true)
  end
  # ---------------------------------------------------------------------
  #   TYPES DE SORTIE
  # ---------------------------------------------------------------------

  def output_as_analyse_tm
    if film.html_file.exist?
      'Les analyse de type “TM” nécessitent une largeur complète, elles s’ouvrent donc dans une autre fenêtre.'.in_p +
      lien_open_analyse_tm
    else
      # <= FILM TM INTROUVABLE
      "Désolé, cette analyse du film “#{film.titre}” est actuellement introuvable…".in_div(class:'air warning') +
      (user.admin? ? "<p class='small'>Fichier recherché : #{film.html_file.to_s}</p>" : "")
    end
  end


  # Note : La méthode <film>.analyse_display est implémentée
  # plus bas dans ce fichier.
  def output_as_analyse_mye
    FilmAnalyse.require_module 'film_MYE'
    <<-HTML
<script type="text/javascript">
  Film.duree = #{film.duree};
</script>
#{film.analyse_display}
    HTML
  end

  # ---------------------------------------------------------------------
  #     MESSAGES
  # ---------------------------------------------------------------------

  def message_film_doesnt_exist
    "Ce film n'existe pas, désolé.".in_div(class:'big air warning')
  end

  def message_film_non_consultable_par_user
    # On construit le message d'interdiction en fonction du film et
    # du statut de l'user
    statut_required, actionlink = case true
    when film.need_subscribed?
      ["abonné", lien.subscribe("#{DOIGT}S'ABONNER (pour #{site.tarif_humain}/AN)").in_span(class:'small')]
    when film.need_signedup?
      ["inscrit", lien.signup("#{DOIGT}S'INSCRIRE (gratuitement)").in_div(class:'small')]
    end

    errmess = "Désolé, cette analyse de film nécessite d'être #{statut_required} pour être consultée."
    errmess += actionlink.in_div(class:'right')
    errmess.in_div(class:'air warning')
  end

end #/<<self
end #/Show

class Film

  # = main =
  #
  # Méthode principale qui affiche un film de type MYE (Md/YAML/EVC)
  #
  def analyse_display
    page.title = "Analyse de film (#{titre})"
    # On reconstruit le fichier dès que c'est l'administrateur
    # qui visite la page, en faisant une version pour lui (avec des
    # boutons et des liens d'édition) et une version pour l'user
    # final.
    if user.admin? || !html_mye_file.exist?
      FilmAnalyse::require_module 'film_MYE_building'
      self.build_analyse_display
    else
      debug "* Chargement du fichier HTML pour l'user de l'analyse de #{titre}"
      html_mye_file.read
    end
  end

end #/Film
end #/FilmAnalyse
