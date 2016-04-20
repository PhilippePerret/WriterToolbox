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
    titre_page = if film.analyse_tm? && !film.analyse_mye?
      ""
    else
      FilmAnalyse::titre_h1( film.titre, {onglets_top: true} )
    end

    titre_page +
    if ! film.exist?
      message_film_doesnt_exist
    elsif ! film.consultable?
      message_film_non_consultable_par_user
    elsif film.analyse_tm? && !film.analyse_mye?
      # Analyse de film de type "TM"
      output_as_analyse_tm
    elsif film.analyse_mye?
      output_as_analyse_mye
    else
      "Analyse mixte"
    end
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
})
</script>
      HTML
    else
      # <= FILM TM INTROUVABLE
      "Désolé, cette analyse du film “#{film.titre}” est actuellement introuvable…".in_div(class:'air warning') +
      (user.admin? ? "<p class='small'>Fichier recherché : #{film.html_file.to_s}</p>" : "")
    end
  end


  def output_as_analyse_mye
    FilmAnalyse::require_module 'film_MYE'
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

  require 'yaml'

  # = main =
  #
  # Méthode principale qui affiche un film de type MYE (Md/YAML/EVC)
  #
  def analyse_display
    site.require_module 'kramdown'

    #  Fichier d'introduction
    # ========================
    # Si un fichier d'introduction existe, il faut le prendre
    intro = if introduction_file.exist?
      introduction_file.kramdown.formate_balises_propres
    else
      ""
    end

    #  Table des matières
    # ====================
    # Fabrication de la table des matières. Cette table des matières
    # peut être définie par un fichier tdm.yaml. Dans le cas où ce
    # fichier n'est pas défini.
    # Quand le fichier tdm.yaml n'existe pas et qu'un affixe de fichier
    # n'a pas pu être trouvé (i.e. c'est un fichier "inconnu") alors on
    # affiche cette alerte pour prévenir un mauvais affichage.
    # Note : @alerte_tdm_pas_etablie_necessaire est défini dans le fichier
    # ./objet/analyse/lib/module/film_MYE/film_extension/instance/tdm.rb
    # dans la méthode `affixe2titre`
    table_of_content = if tdm_file.exist? || @alerte_tdm_pas_etablie_necessaire.nil?
      ""
    else
      "La table des matières de cette analyse n'est pas encore établie. Les fichiers sont dont affichés “tels quels” ici.".in_div(class:'grand air warning')
    end

    ititre = 0
    table_of_content << tdm.collect do |fdata|
      ititre += 1
      fdata.merge!(anchor: "titre#{ititre.to_s.rjust(4,'0')}")
      fdata[:titre].in_a(href:"#{route_courante}##{fdata[:anchor]}").in_li(class:'tdm_item')
    end.join.in_ul(class:'tdm')

    #  L'analyse intégrale
    # =====================
    # Le contenu intégral de tous les fichiers, en fonction de
    # leur format, c'est-à-dire soit des fichiers YAML qui sont
    # kramdownés, soit des fichiers YAMLS dont les données sont
    # traitées en fonction du type, soit enfin des évènemenciers
    # traités par le module adéquat.
    whole_content = tdm.collect do |fdata|

      # Path du fichier -> SuperFile
      frelpath = fdata[:path]
      fpath   = folder_in_films_mye + frelpath
      sfile = ( SuperFile::new fpath )

      # Titre du document
      ftitre  = fdata[:titre].nil? ? "" : "<h3>#{fdata[:titre]}</h3>"

      # Un lien pour éditer le fichier si c'est l'administrateur
      # ou un analyse
      lien_edit_file = if user.admin? || user.analyste?
        lien.edit_file(sfile.expanded_path).in_div(class:'right')
      else
        ""
      end

      (
        "<a name='#{fdata[:anchor]}'></a>\n" +
        ftitre +
        (
          lien_edit_file +
          case sfile.extension
          when 'md'   then sfile.as_kramdown
          when 'yaml' then sfile.as_yaml
          when 'evc'
            require_module_evc_if_needed
            sfile.as_evc
          else
            # Extension inconnue, on lit le fichier tel quel
            sfile.read
          end
        ).in_section
      ).in_section
    end.join

    # L'intégralité de la page d'analyse
    return (
        intro +
        "Table des matières".in_h3 +
        table_of_content +
        whole_content
      ).in_section
  end

  def require_module_evc_if_needed
    return if @module_evc_loaded
    FilmAnalyse::require_module 'evc'
    @module_evc_loaded = true
  end

end #/Film
end #/FilmAnalyse
