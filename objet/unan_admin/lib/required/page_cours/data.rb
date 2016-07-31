# encoding: UTF-8
=begin

Méthodes d'instance de UnanAdmin::PageCours

Méthodes commune à toutes les vues du dossier page_cours et peut-être
même au-delà.

=end
site.require_objet 'unan'
site.require_module 'page_cours'

class Unan
class Program
class PageCours

  def content
    @content ||= begin
      create_file_page_cours unless fullpath.exist?
      fullpath.read
    end
  end

  # Crée le fichier de cours s'il n'existe pas et que la
  # case à cocher "créer le fichier" est coché
  def create_file_page_cours
    return if fullpath.exist?
    idandtitre = "##{id} #{titre}"
    content =
      case fullpath.extension
      when 'txt'
        "[Contenu de la page #{titre}]"
      when 'tex'
        "% Page #{titre}\n\n[Contenu de la page #{idandtitre}]"
      when 'erb'
        "<%\n# #{idandtitre} \n%>\n<h3>#{titre}</h3>\n<p>[Contenu de la page #{titre}]</p>"
      when 'html', 'htm'
        "<h3>#{titre}</h3>\n<p>[Contenu de la page #{titre}]</p>"
      when 'md'
        "<!-- Contenu de la page #{idandtitre} -->\n\n"
      else
        flash "l'extension #{fullpath.extension} n'est pas traitée dans la création automatique des fichiers."
        nil
      end
    return if content.nil?
    fullpath.write content
    if fullpath.exist?
      flash "Le fichier a été créé avec succès."
    else
      error "Le fichier n'a pas pu être créé pour une raison inconnue."
    end
  end

  def data
    @data ||= table_pages_cours.get(id)
  end

  # Type de la page (page UN AN, ou narration, ou
  # collection narration)
  def type
    @type ||= data[:type] || get(:type)
  end

  def table_pages_cours
    @table_pages_cours ||= Unan.table_pages_cours
  end
  alias :table :table_pages_cours

end #/PageCours
end #/Program
end #/UnanAdmin

# Retourne l'instance UnanAdmin::PageCours de la page courante, mais seulement
# si elle est définie par l'url RestFull.
# TODO Peut-être qu'il vaudrait mieux mettre ça dans un module plutôt que
# dans cette libraire tout le temps required.
def page_cours
  @page_cours ||= begin
    if site.current_route.objet == "page_cours" && site.current_route.objet_id
      Unan::Program::PageCours::new( site.current_route.objet_id )
    else
      nil
    end
  end
end
