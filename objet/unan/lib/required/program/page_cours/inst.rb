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
  class << self

    def table_pages_cours
      @table_pages_cours ||= site.db.create_table_if_needed('unan', 'pages_cours')
    end
    
  end # << self PageCours
  # Pointeur
  attr_reader :handler

  def initialize handler
    @handler = handler
  end
  # Retourne l'instance ou raise une erreur si la page n'existe pas
  def self_if_exists_or_raise
    return self unless db_data.nil?
    raise ArgumentError, "Page de cours introuvable (#{handler.inspect})"
  end

  def db_data
    @db_data ||= table.get(where:"handler = '#{handler}'")
  end

  def table
    @table ||= self.class::table_pages_cours
  end
end #/PageCours
end #/Program
end #/Unan
