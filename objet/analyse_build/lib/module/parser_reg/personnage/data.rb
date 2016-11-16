# encoding: UTF-8
=begin

  Module principal de parsing du fichier brins

=end
class AnalyseBuild
class Film
class Personnage

  attr_reader :id
  attr_reader :patronyme, :prenom, :nom, :pseudo, :fonction

  # Toutes les données sous forme de Hash qui doivent être enregistrées
  # dans le fichier Marshal
  def all_data
    {
      id:         id,
      patronyme:  patronyme,
      prenom:     prenom,
      nom:        nom,
      pseudo:     pseudo,
      fonction:   fonction
    }
  end

end #/Personnage
end #/Film
end #/AnalyseBuild
