# encoding: UTF-8
class Unan
class Program
class PageCours
  class << self

    def get pref
      case pref
      when Symbol, Fixnum then new( pref )
      else raise "[Unan::Program::PageCours] Il faut fournir l'ID ou le Handler de la page."
      end
    end

    # Table des pages de cours
    def table_pages_cours
      @table_pages_cours ||= site.db.create_table_if_needed('unan', 'pages_cours')
    end
    alias :table :table_pages_cours

  end # << self
end #/PageCours
end #/Program
end #/Unan
