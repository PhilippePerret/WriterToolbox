# encoding: UTF-8
=begin

  Module principal de parsing du fichier brins

=end
class AnalyseBuild
class Film
class Brin

  attr_reader :id, :titre, :description

  # Toutes les données sous forme de Hash qui doivent être enregistrées
  # dans le fichier Marshal des brins
  def all_data
    {
      id: id, titre: titre, description: description
    }
  end

end #/Brin
end #/Film
end #/AnalyseBuild
