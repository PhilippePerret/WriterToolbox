# encoding: UTF-8
=begin

=end
class Unan
class Program

  # {Unan::Programm::PageCours} Returne une instance de page
  # de cours.
  # @usage program.page_cours <handler>
  def page_cours page_handler
    unless @module_page_cours_required
      Unan::require_module 'page_cours'
      @module_page_cours_required = true
    end
    page_handler = page_handler.to_sym if page_handler.instance_of?(String)
    raise ArgumentError, "Unan::Program#page_cours attend en argument un Symbol ou un String" unless page_handler.instance_of?(Symbol)
    PageCours::new(page_handler).self_if_exists_or_raise
  end

  class PageCours

    # Instanciation de la page de cours, soit avec l'ID soit
    # avec son handler
    def initialize pref
      case pref
      when Symbol then @handler = pref
      when Fixnum then @id      = pref
      else raise "Une instance Unan::Program::PageCours doit être initialisée avec un handler ou un ID."
      end
    end

    def bind; binding() end

    # Retourne l'instance ou raise une erreur si la page n'existe pas
    def self_if_exists_or_raise
      return self unless data.nil?
      raise ArgumentError, "Page de cours introuvable (#{handler.inspect})"
    end


    def get_id
      # -> MYSQL UNAN
      table.select(where:"handler = '#{handler}'", colonnes:[:id]).values.first[:id]
    end

    # Retourne toutes les données
    # NOTE Surclasse la méthode du module MethodesObjetsBdD car on
    # peut utiliser ici l'ID ou le handler.
    def data
      @data ||= begin
        if handler != nil
          table.get(where:"handler = '#{handler}'")
        elsif id != nil
          table.get(id)
        else
          nil
        end
      end
    end

    def table
      # -> MYSQL UNAN
      @table ||= self.class::table_pages_cours
    end

  end #/PageCours
end #/Program
end #/Unan
