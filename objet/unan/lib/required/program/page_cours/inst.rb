# encoding: UTF-8
=begin

=end
class Unan
class Program

  # {Unan::Programm::PageCours} Returne une instance de page
  # de cours.
  # @usage program.page_cours <handler>
  def page_cours page_handler
    page_handler = page_handler.to_sym if page_handler.instance_of?(String)
    raise ArgumentError, "Unan::Program#page_cours attend en argument un Symbol ou un String" unless page_handler.instance_of?(Symbol)
    PageCours::new(page_handler).self_if_exists_or_raise
  end

  class PageCours

    include MethodesObjetsBdD

    # ID
    attr_reader :id
    # Pointeur
    attr_reader :handler

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

    # ---------------------------------------------------------------------
    #   Données base de la page
    # ---------------------------------------------------------------------

    def id        ; @id       ||= get_id        end
    def handler   ; @handler  ||= get(:handler) end
    def titre     ; @titre    ||= get(:titre)   end
    def path      ; @path     ||= get(:path)    end
    def type      ; @type     ||= get(:type)    end

    # ---------------------------------------------------------------------
    #   Propriétés volatile de la page
    # ---------------------------------------------------------------------

    def extension
      @extension ||= File.extname(path)[1..-1]
    end
    def fullpath
      @fullpath ||= Unan::main_folder_data + "pages_cours/#{type}/#{path}"
    end

    #
    # ---------------------------------------------------------------------


    def get_id
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
      @table ||= self.class::table_pages_cours
    end

  end #/PageCours
end #/Program
end #/Unan
