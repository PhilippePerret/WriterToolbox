# encoding: UTF-8
=begin

  Module principal de parsing du fichier brins

=end
class AnalyseBuild
class Film
class Brin
  
  attr_reader :film

  # Le code brut dans le fichier (toutes les lignes)
  attr_reader :code

  # Instanciation du brin
  #
  # Cette méthode est propre au parsing du fichier, elle sera écrasée
  # lorsqu'on passera à la construction des éléments
  #
  def initialize film, code
    @film = film
    @code = code
    parse
  end

end #/Brin
end #/Film
end #/AnalyseBuild
