# encoding: UTF-8
=begin
Méthodes d'helper
=end
require 'yaml'

class FilmAnalyse
class Film

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
    ititre = 0
    table_of_content = tdm.collect do |fdata|
      ititre += 1
      fdata.merge!(anchor: "titre#{ititre.to_s.rjust(4,'0')}")
      fdata[:titre].in_a(href:"#{route_courante}##{fdata[:anchor]}").in_li(class:'tdm_item')
    end.join.in_ul(class:'tdm')

    #  Contenu intégral
    # ==================
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
      ).in_div( class:'section' )
    end.join

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

  def tdm
    @tdm ||= begin
      if tdm_file.exist?
        tdm_file.deyamelize
      else
        # Si aucun fichier tdm existe, on relève la liste
        # des fichiers dans les dossiers de l'analyse en
        # mettant en titre le nom du fichier
        Dir["#{folder_in_films_mye}/**/*.*"].collect do |fpath|
          {
            titre:  File.basename(fpath, File.extname(fpath)),
            path:   fpath.gsub(/#{folder_in_films_mye}\//,'')
          }
        end
      end
    end
  end

end # /Film
end # /FilmAnalyse
