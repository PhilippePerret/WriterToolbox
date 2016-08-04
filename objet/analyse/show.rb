# encoding: UTF-8

page.title = "Analyses de films"

def film; @film ||= FilmAnalyse::Film::current end

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
        ""
      else
        FilmAnalyse::titre_h1( film.titre, {onglets_top: true} )
      end

    titre_page +
    if ! film.exist?
      message_film_doesnt_exist
    elsif ! film.consultable?
      message_film_non_consultable_par_user +
      fiche_film
    elsif film.analyse_tm? && !film.analyse_mye?
      # Analyse de film de type "TM"
      output_as_analyse_tm
    elsif film.analyse_mye?
      fiche_film +
      output_as_analyse_mye
    else
      "Analyse mixte"
    end
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
      <<-HTML
<iframe
  id="frame_analyse"
  width="100%"
  height="100%"
  src="#{film.html_file.to_s}"
  style="position:fixed;top:0;left:0"></iframe>
<div id="div_bouton_back"><a href="analyse/list">Liste analyses</a></div>
<script type="text/javascript">
$(document).ready(function(){
  $('section').hide();
  $('section#content').show();
  var l = ['form#taches_widget', 'section#social_network', 'div#div_permanent_link'];
  $(l).each(function(i,o){$(o).hide()})
})
</script>
      HTML
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
    when film.need_suscribed?
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
