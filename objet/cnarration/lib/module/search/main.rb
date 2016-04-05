# encoding: UTF-8
=begin
Module de recherche principal

=end
class Cnarration
class Search
  class << self
    # La recherche courante
    attr_reader :current_search

    # Retourne le code HTML pour la recherche effectuée
    def result
      return "" if current_search.nil?
      current_search.output
    end

    # Procède à la recherche d'après les éléments définis
    def proceed
      @current_search = new()
      @current_search.proceed
    end

  end # / << self
end #/Search
end #/Cnarration
