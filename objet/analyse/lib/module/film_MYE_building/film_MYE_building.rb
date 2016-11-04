# encoding: UTF-8
=begin

  Pour la construction d'une analyse de film MYE

  Ce module est appelé par la méthode show.rb qui affiche les films
  d'analyse MYE.

=end


require 'yaml'
# Pour composer les ancres uniques
require 'digest/md5'

class FilmAnalyse
class Film

  # Constructeur d'une analyse de film MYE
  #
  # Noter que cette construction ne peut être faite que par un
  # administrateur ou un analyste.
  # Elle produit un code pour l'admin avec des liens d'édition
  # et un autre code pour l'user sans ces liens.
  #
  def build_analyse_display

    site.require_module 'kramdown'

    #  Fichier d'introduction
    # ========================
    # Si un fichier d'introduction existe, il faut le prendre
    intro =
      if introduction_file.exist?
        introduction_file.kramdown.formate_balises_propres
      else
        ""
      end

    # Si un timeline des scènes existe, il faut le
    # charger
    timeline_scenes =
      if timeline_scenes_file.exist?
        timeline_scenes_file.read
      else
        ""
      end


    # Un lien pour obtenir la balise conduisant
    # à cette analyse
    relative_url = "analyse/#{id}/show"
    absolute_url = "#{site.distant_url}/#{relative_url}"
    clips = Array::new
    permanent_link = if user.admin?
      clips << "'Mardown':'[Analyse de “#{titre}”](#{relative_url})'"
      clips << "'Mail/Forum':'ALINK[#{absolute_url}, Analyse de #{titre}]'"
      onclick = "UI.clip({#{clips.join(',')}})"
      "&lt;lien vers cette analyse&gt;".in_a(onclick:"#{onclick}")
    else
      "Lien permanent : " + absolute_url.in_input_text(name:'permanent_link', style:'font-size:9pt;width:300px', onfocus:"this.select()")
    end
    permanent_link = permanent_link.in_div(class:'right', style:'font-size:9pt')


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
    table_of_content =
      if tdm_file.exist? || @alerte_tdm_pas_etablie_necessaire.nil?
        ""
      else
        "La table des matières de cette analyse n'est pas encore établie. Les fichiers sont donc affichés “tels quels” ici.".in_div(class:'grand air warning')
      end

    # On ne met la table des matières que s'il y a plus de
    # deux fichiers d'analyse ou que le texte est assez long
    # Pour le moment, on la construit quand même toujours
    #
    # C'est important ici pour créer les ancres des
    # fichiers en fonction de leur nom.
    table_of_content << "Table des matières".in_h3
    ititre = 0
    table_of_content <<
      tdm.collect do |fdata|
        ititre += 1
        ancre = "#{fdata[:path]}#{fdata[:titre]}".as_normalized_id.downcase
        ancre = "lk" + Digest::MD5.hexdigest("#{ancre}")
        fdata.merge!(anchor: ancre)
        fdata[:titre].in_a(href:"#{route_courante}##{fdata[:anchor]}").in_li(class:'tdm_item')
      end.join.in_ul(class:'tdm')


    table_of_content = "" if tdm.count < 3

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
      sfile = ( SuperFile.new fpath )
      fdata.merge!( sfile: sfile )
      # Une ancre éventuelle ajouté au-dessus du titre
      ancre = fdata[:ancre] ? "<a name=\"#{fdata[:ancre]}\"></a>" : ''

      # Titre du document (avec ancre éventuelle)
      ftitre  = ancre + ( fdata[:titre] ? "<h3>#{fdata[:titre]}</h3>" : '')

      # Incipit
      fincipit = fdata[:incipit].nil? ? "" : fdata[:incipit].in_p(class:'italic small')

      # Introduction
      fintroduction = fdata[:introduction].nil? ? "" : fdata[:introduction].in_div(class:'small')

      # Conclusion
      fconclusion = fdata[:conclusion].nil? ? "" : fdata[:conclusion].in_div(class:'small')

      (
        "<a name='#{fdata[:anchor]}'></a>\n" +
        ftitre +
        fincipit +
        fintroduction +
        (
          '<ADMIN>' + box_edition(fdata) + '</ADMIN>' +
          case sfile.extension
          when 'md'   then sfile.as_kramdown
          when 'yaml' then sfile.as_yaml
          when 'evc'
            require_module_evc_if_needed
            sfile.as_evc #.in_section(class:'document evc')
          else
            # Extension inconnue, on lit le fichier tel quel
            sfile.read
          end
        ).in_section +
        fconclusion
      ).formate_balises_propres.in_section
    end.join

    # Pour terminer, si c'est l'administrateur ou un
    # analyste qui visite la page, je vais placer en regard des
    # titre un lien pour obtenir le tag à cette partie, à partir
    # de l'identifiant attribué par Kramdown
    # Noter qu'elles sont placées ici tout le temps car :
    #   1. C'est toujours l'administrateur qui passe par ic
    #   2. Elles sont mises entre balises admin qui seront
    #      détruites pour composer le code du fichier final
    #      pour l'user.
    whole_content = place_boutons_pour_balise_in(whole_content)

    # L'intégralité de la page d'analyse
    whole_code_file = (
      permanent_link +
      intro +
      timeline_scenes +
      table_of_content +
      whole_content +
      permanent_link
      ).in_section

    # On fait le fichier de l'user final en supprimant
    # tous les codes réservés à l'administration
    whole_code_file_user = whole_code_file.gsub(/<ADMIN>(.*?)<\/ADMIN>/,'')

    # On enregistre le code dans un fichier HTML
    html_mye_file.remove if html_mye_file.exist?
    html_mye_file.write whole_code_file_user

    # On retourne le code pour l'administrateur
    return whole_code_file
  end


  # Ajoute des liens-boutons pour obtenir un lien ou une
  # balise vers les sous-parties de l'analyse
  def place_boutons_pour_balise_in code
    file_url = "analyse/#{id}/show"
    code.gsub(/<(h[2-6])(?:.*?)id="(.+?)"(?:.*?)>(.+?)<\/\1>/){
      tout      = $&.freeze
      titre_id  = $2.freeze
      titre_nom = $3.freeze
      titre_complet = "Analyse de #{titre}, #{titre_nom}"
      relative_url = "#{file_url}##{titre_id}"
      absolute_url = "#{site.distant_url}/#{relative_url}"
      clips = ["'BRUT': '#{relative_url}'"]
      clips << "'MD Loc': '[#{titre_nom}](#{relative_url})'"
      clips << "'MD Dist':'[#{titre_complet}](#{absolute_url})'"
      clips << "'Markdown': '[#{titre_complet}](#{absolute_url})'"
      clips << "'Mail': 'ALINK[#{absolute_url},#{titre_complet}]'"
      clips = "{#{clips.join(',')}}"
      box = "&lt;lien&gt;".in_a(onclick:"UI.clip(#{clips})").in_div(class:'fright small')
      "<!-- ADMIN -->#{box}#{tout}<!-- /ADMIN -->"
    }
  end

  # Boite de boutons d'édition pour la page courante, si c'est
  # un administrateur ou un analyste.
  def box_edition fdata
    btns = ""

    if user.admin? || user.analyste?
      # Le lien pour ouvrir le fichier Markdown (dans TextMate)
      btns += lien.edit_file(fdata[:sfile].expanded_path)
    end

    # debug "fdata : #{fdata.inspect}"
    titre_complet = "Analyse de #{titre}, #{fdata[:titre]}"

    # Le lien pour obtenir une balise vers ce fichier
    # d'analyse
    ancre = "##{fdata[:anchor]}"
    clips = Array::new
    if user.admin? || user.analyste?
      clips = ["'Ici':'#{ancre}'"]
      url   = "analyse/#{id}/show#{ancre}"
      clips << "'Site': '#{url}'"
      clips << "'URL Loc': '#{site.url_locale}/#{url}'"
    end
    url_distante = "#{site.url_distante}/#{url}"
    clips << "'HREF': '#{url_distante}'"
    clips << "'Lien': 'ALINK[#{url_distante},#{titre_complet}]'"

    btns += "&lt;lien&gt;".in_a(onclick:"UI.clip({#{clips.join(', ')}})")

    # On construit la boite et on la renvoie
    btns.in_div(class:'small right btns')
  end

  def require_module_evc_if_needed
    return if @module_evc_loaded
    FilmAnalyse::require_module 'evc'
    @module_evc_loaded = true
  end

end #/Film
end #/FilmAnalyse
