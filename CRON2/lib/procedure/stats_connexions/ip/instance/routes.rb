# encoding: UTF-8
=begin

  Instance Connexions::IP
  -----------------------
  Pour le traitement d'un IP en particulier

=end
class Connexions
class IP

  # {Array de Connexions::Route}
  # On recalcule chaque fois la liste des routes (pour les
  # tests notamment et parce que ça ne sera pas appelé souvent)
  #
  def routes
    l = Array.new
    routes_traited = Hash.new
    connexions.each do |conn|
      if routes_traited.key?(conn.route)
        # Une route déjà traitée
        # ----------------------
        # => Il faut ajouter sa durée réelle d'utilisation
        routes_traited[conn.route].add_duree_reelle(conn.duree)
      else
        # Une nouvelle route
        # ------------------
        conroute = Connexions::Connexion::Route.new(conn)
        routes_traited.merge!(conn.route => conroute)
        l << conroute
      end
    end
    l
  end

  def nombre_routes
    routes.count
  end
end #/IP
end #/Connexions
