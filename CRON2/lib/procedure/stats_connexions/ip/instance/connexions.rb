# encoding: UTF-8
=begin

  Instance Connexions::IP
  -----------------------
  Pour le traitement d'un IP en particulier
  Méthodes gérant les connexions

=end
class Connexions
class IP

  # Ajoute une instance Connexions::Connexion à la liste
  # des connexions de l'ip
  # +iconnexion+ {Connexions::Connexion}
  def add_connexion iconnexion
    @connexions ||= Array.new
    @connexions << iconnexion
  end

  # Retourne le nombre de connexions de cette IP au site
  def nombre_connexions
    @connexions ||= Array.new
    @connexions.count
  end

end #/IP
end #/Connexions
