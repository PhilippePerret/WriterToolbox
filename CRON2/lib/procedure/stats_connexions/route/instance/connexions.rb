# encoding: UTF-8
=begin

  Instance Connexions::Route
  ---------------------------
  Pour le traitement d'une route en particulier
  Méthodes gérant les connexions

=end
class Connexions
class Route

  # Ajoute une instance Connexions::Connexion à la liste
  # des connexions de l'ip
  # +iconnexion+ {Connexions::Connexion}
  def add_connexion iconnexion
    @connexions ||= Array.new
    @connexions << iconnexion
  end

end #/Route
end #/Connexions
