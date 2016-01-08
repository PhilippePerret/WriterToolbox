# encoding: UTF-8
=begin

Instances Unan
--------------
Gestion d'un programme en particulier
C'est donc le programme suivi par un user inscrit et à jour de ses paiements.

=end
class Unan
class Program

  def initialize id
    @id = id

    # Pour contenir tous les jours de la propriété
    # days_overview (cf. le fichier dev Days-overview.md)
    @all_days_overview = Array::new
    
  end

end #/Program
end #/Unan
