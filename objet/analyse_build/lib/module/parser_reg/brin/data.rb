# encoding: UTF-8
=begin

  Module principal de parsing du fichier brins

=end
class AnalyseBuild
class Film
class Brin


  # Toutes les données sous forme de Hash qui doivent être enregistrées
  # dans le fichier Marshal des brins
  def all_data
    {
      id: id, titre: titre, description: description
    }
  end

  def id
    @id != nil || parse
    @id
  end

  def titre
    @titre != nil || parse
    @titre
  end

  def description
    @description != nil || parse
    @description
  end

end #/Brin
end #/Film
end #/AnalyseBuild
