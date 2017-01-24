# encoding: UTF-8
=begin
Méthode qui permettent de procéder à l'analyse des connexions
au site
=end
class Connexions
class Connexion
class << self

  # {Hash} Tableau contenant tous les résultats de l'analyse
  # des connexions.
  attr_reader :resultats_analyse
  alias :resultats :resultats_analyse
  # = main =
  #
  # Méthode principale procédant à l'analyse des connexions
  #
  def analyse
    uptime = Time.now.to_i
    init_analyse
    @resultats_analyse[:time] = uptime

    # On passe en revue toutes les connexions
    list_upto(uptime).each do |iconnexion|
      iconnexion.ip != 'TEST' || next

      # Est-ce une nouvelle IP
      @resultats_analyse[:per_ip].key?(iconnexion.ip) || begin
        ip_instance = Connexions::IP.new(iconnexion.ip)
        @resultats_analyse[:per_ip].merge!(
          iconnexion.ip => ip_instance
        )
      end

      # On ajoute cette connexion à l'IP ({Connexions::IP})
      @resultats_analyse[:per_ip][iconnexion.ip].add_connexion(iconnexion)

      # Est-ce une nouvelle Route ?
      @resultats_analyse[:per_route].key?(iconnexion.route) || begin
        route_instance = Connexions::Route.new(iconnexion.route)
        @resultats_analyse[:per_route].merge!(
          iconnexion.route => route_instance
        )
      end

      # On ajoute cette connexion à la route ({Connexions::Route})
      @resultats_analyse[:per_route][iconnexion.route].add_connexion(iconnexion)

    end
  end
  def init_analyse
    @resultats_analyse = {
      time:       nil,
      per_ip:     Hash.new,
      per_route:  Hash.new,
      parcours:   Array.new
    }
  end

  # Initialisation avant l'analyse
  # Peut être aussi appelé seul pour les tests
  def init
    @resultats_analyse = nil
  end

end #/<< self
end #/Connexion
end #/Connexions
