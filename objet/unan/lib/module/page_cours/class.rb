# encoding: UTF-8
class Unan
class Program
class PageCours

  # Le type de page
  # Maintenant il n'y a plus que deux types : soit c'est une page
  # qui appartient au programme UN AN UN SCRIPT (donc qui ne peut
  # pas être une page de cours) soit c'est une page de la collection
  # narration qui reprend toutes les anciennes pages du livre
  # Narration
  TYPES_PAGE = {
    'U' => {type: 'U', hname:"Programme UN AN UN SCRIPT", folder: 'program'},
    'N' => {type: 'N', hname:"Collection Narration", folder: 'cnarration'}
  }

  class << self

    # {Unan::Program::PageCours} retourne l'instance PageCours
    # de la page de cours.
    def get pref
      case pref
      when Symbol, Fixnum then new( pref )
      else raise "[Unan::Program::PageCours] Il faut fournir l'ID ou le Handler de la page."
      end
    end

    # Table des pages de cours
    def table_pages_cours
      @table_pages_cours ||= Unan.table_pages_cours
    end
    alias :table :table_pages_cours

  end # << self
end #/PageCours
end #/Program
end #/Unan
