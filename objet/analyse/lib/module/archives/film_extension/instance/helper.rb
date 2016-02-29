# encoding: UTF-8
=begin
Méthodes d'helper
=end
require 'yaml'

class SuperFile
  def deyamelize
    # YAML::parse(read)
    # YAML::load(read)
    Psych.load_file(self.to_s).to_sym
  end
end

class FilmAnalyse
class Film

  # Toutes les données rassemblées
  def all_data
    site.require_module 'kramdown'

    debug "tdm: #{tdm.inspect}::#{tdm.class}"

    # Fabriquer la table des matières
    ititre = 0
    table_of_content = tdm.collect do |fdata|
      ititre += 1
      fdata.merge!(anchor: "titre#{ititre.to_s.rjust(4,'0')}")
      fdata[:titre].in_a(href:"#{site.current_route.route}##{fdata[:anchor]}").in_li(class:'tdm_item')
    end.join.in_ul(class:'tdm')

    content = tdm.collect do |fdata|
      frelpath = fdata[:path]
      fpath   = folder_in_archives + frelpath
      ftitre  = fdata[:titre]
      sfile = ( SuperFile::new fpath )

      (
        "<a name='#{fdata[:anchor]}'></a>\n" +
        (ftitre.nil? ? "" : "<h3>#{ftitre}</h3>") +
        "<section>" +
        (user.admin? ? lien.edit_file(fpath).in_div(class:'right') : "") +
        case sfile.extension
        when 'md'   then sfile.kramdown
        when 'yaml' then sfile.deyamelize.inspect
        else
          # Extension inconnue, on lit le fichier tel quel
          sfile.read
        end +
        "</section>"
      ).in_div(class:'section')
    end.join

    return table_of_content + content
  end

  def tdm
    @tdm ||= begin
      if tdm_file.exist?
        tdm_file.deyamelize
      else
        # Si aucun fichier tdm existe, on relève la liste
        # des fichiers dans les dossiers de l'analyse en
        # mettant en titre le nom du fichier
        Dir["#{folder_in_archives}/**/*.*"].collect do |fpath|
          {
            titre:  File.basename(fpath, File.extname(fpath)),
            path:   fpath.gsub(/#{folder_in_archives}\//,'')
          }
        end
      end
    end
  end

end # /Film
end # /FilmAnalyse
