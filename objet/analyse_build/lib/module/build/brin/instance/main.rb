# encoding: UTF-8
=begin

  Module principal de parsing du fichier brins

=end
class AnalyseBuild
class Film
class Brin
  attr_reader :film

  # Les données du brin, enregistrées dans le fichier Marshal
  attr_reader :data

  # Instanciation du brin
  #
  # Cette méthode écrase la méthode d'initialisation courante, par exemple
  # celle qui permet de parser le fichier.
  #
  def initialize data
    # @film = film
    @data = data
    data.each{|k,v|instance_variable_set("@#{k}",v)}
  end
  

end #/Brin
end #/Film
end #/AnalyseBuild
