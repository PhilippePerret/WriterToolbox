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
  # Contient :
  #   :time     Le temps limite pour que la connexion soit prise
  #             en compte. Fixnum
  #   :per_ip   {Hash} La liste des toutes les connexions, avec en
  #             clé l'IP et en valeur l'instance Connexions::IP
  #             Si un moteur de recherche a utilisé plusieurs IP, on
  #             ne le voit pas dans ce tableau.
  #   :per_user {Hash} Tableau de toutes les connexions, avec en clé
  #             SOIT l'ip (si particulier) SOIT l'human_id (si moteur de
  #             recherche) et en valeur la première instance connexion
  #             {Connexions::IP} avec toutes les connexions qui ont été
  #             effectuées (pour le moment, seuls les moteurs sont concernés
  #             par le fait d'avoir plusieurs IP)
  #   :per_route  {Hash} contenant en clé la route demandée et en valeur
  #               une instance Connexions::Route
  #
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
      if @resultats_analyse[:per_ip].key?(iconnexion.ip)
        # Adresse IP ayant déjà été traitée
        # On met le temps de fin à la dernière connexion
        @resultats_analyse[:per_ip][iconnexion.ip].set_end_time_last_connexion_to(iconnexion.time)
      else
        # Si c'est une nouvelle connexion
        ip_instance = Connexions::IP.new(iconnexion.ip)
        @resultats_analyse[:per_ip].merge!(
          iconnexion.ip => ip_instance
        )
      end

      # On ajoute cette connexion à l'IP ({Connexions::IP}) en définissant
      #
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
    # /Fin de boucle sur toutes les rangées de la table connexions_per_ip
    # On fait le tableau :per_user
    analyse_per_user
  end

  # Analyse des connexions par user, un user pouvant être une ip
  # ou un moteur de recherche avec plusieurs IP.
  def analyse_per_user
    resultats[:per_ip].each do |ip, dip|
      if dip.search_engine?
        # Un moteur de recherche
        # ----------------------
        # Soit il faut initier sa rangée dans :per_user, soit cette rangée
        # existe déjà et il faut lui ajouter les connexions de l'instance
        # Connexions::IP courante
        if @resultats_analyse[:per_user].key?(dip.search_engine.human_id)
          # La donnée du moteur de recherche existe déjà dans :per_user
          dip.connexions.each do |conn|
            @resultats_analyse[:per_user][dip.search_engine.human_id].add_connexion(conn)
          end
        else
          # La donnée du moteur n'existe pas encore dans :per_user
          @resultats_analyse[:per_user].merge!(
            dip.search_engine.human_id => dip.clone
          )
        end
      else
        # Un particulier
        # --------------
        # On ajoute simplement la même donnée
        @resultats_analyse[:per_user].merge!(ip => dip)
      end
    end
  end

  def init_analyse
    @resultats_analyse = {
      time:       nil,
      per_ip:     Hash.new,
      per_user:   Hash.new,
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
