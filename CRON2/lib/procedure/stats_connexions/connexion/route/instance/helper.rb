# encoding: UTF-8
=begin
  Instance Connexions::Connexion::Route
  -------------------------------------
  Méthodes d'helper pour les routes
=end
class Connexions
class Connexion
class Route

  # Retourne une route liée à sa route
  def linked_route options = nil
    @linked_route ||= begin
      route.in_a(href: "#{site.distant_url}/#{route}")
    end
  end


end #/Route
end #/Connexion
end #/Connexions
