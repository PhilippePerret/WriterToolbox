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


  # Permet de définir le temps de fin de la dernière connexion
  # enregistrée.
  def set_end_time_last_connexion_to end_time
    if nombre_connexions > 0
      connexions.last.end_time = end_time
    end
  end

end #/IP
end #/Connexions
