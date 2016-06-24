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
      fullpath.read
    end
  end

  def data
    @data ||= table_pages_cours.get(id)
  end

  # Type de la page (page un an un script, ou narration, ou
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
