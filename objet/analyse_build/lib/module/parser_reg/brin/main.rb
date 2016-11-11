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

  def initialize film, code
    @film = film
    @code = code
  end

end #/Brin
end #/Film
end #/AnalyseBuild
