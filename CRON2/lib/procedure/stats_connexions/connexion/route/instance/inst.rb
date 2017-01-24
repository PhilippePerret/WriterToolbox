# encoding: UTF-8
=begin
  Instance Connexions::Connexion::Route
  Permet de gérer le connexion en tant que route, en ne
  créant qu'une seule instance pour plusieurs connexions qui ont
  la même route, ce qui permet de gérer le temps.

  Cette instance n'est pas à confondre avec Connexions::Route qui
  gère les routes par les routes données. Ici, une route est
  toujours attachée à une connexion tandis que dans Connexions::Route
  une route contient plusieurs connexions de possesseur (IP) différents.

=end
class Connexions
class Connexion
class Route

  def initialize iconnexion
    @connexion = iconnexion
  end


end #/Route
end #/Connexion
end #/Connexions
