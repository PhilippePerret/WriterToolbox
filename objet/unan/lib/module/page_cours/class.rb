# encoding: UTF-8
class Unan
class Program
class PageCours

  TYPES_PAGE = {
    program:      {hname:"Programme UN.AN.UN.SCRIPT"},
    narration:    {hname:"Livre Narration"},
    cnarration:   {hname:"Collection Narration"}
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
      @table_pages_cours ||= site.db.create_table_if_needed('unan_cold', 'pages_cours')
    end
    alias :table :table_pages_cours

  end # << self
end #/PageCours
end #/Program
end #/Unan
