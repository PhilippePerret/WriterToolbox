# encoding: UTF-8
class TestedPage

  class << self

    # {Hash} comportant en clé la route de la page testée
    # et en valeur l'instance TestedPage qui contient toutes
    # les données.
    attr_reader :instances

    # # {Hash} GROSSE TABLE CONTENANT TOUS LES RÉSULTATS
    # # OBSOLÈTE. Voir @instances, maintenant
    # attr_reader :hroutes

    # {Array} de toutes les routes à tester. On s'arrête lorsque
    # la liste est vide.
    # Les éléments sont les routes, donc les clés des instances, qu'on
    # peut récupérer par :
    #   TestedPage[<route>]
    attr_reader :routes



    # Liste des routes des pages (instances TestedPage) invalides
    # Note : dans leur @errors, on trouve la liste de leurs
    # erreurs.
    #
    # Pour les récupérer en tant qu'instance TestedPage, on
    # peut utiliser: TestedPage[<id>]
    #
    attr_reader :invalides

    # Compte total de liens
    attr_accessor :links_count

    def base_url
      @base_url ||= online? ? BASE_URL : BASE_URL_LOCAL
    end
    def online?
      TEST_ONLINE
    end

    def init
      @instances    = Hash.new
      @invalides    = Array.new
      @links_count  = 0
    end

    # Ajoute une page invalide
    #
    # On pourrait passer en revue chaque instance TestedPage,
    # mais la variable @invalides sera plus pratique.
    def add_invalide route
      @invalides << route
    end

    # Ajouter l'instance +instance+ dans la liste des instances
    #
    # Note : +route_init+ est la route ayant servi à l'instanciation
    # de l'instance, avec l'ancre si elle en contient une. C'est
    # ce qui fait que 'ma/route' et 'ma/route#avec_ancre' produisent
    # deux instances TestedPage différentes (mais qui seront mergées)
    # à la fin du check de validité.
    def << instance
      @instances.merge! instance.route_init => instance
    end

    # Retourne l'instance +route+ des instances de TestedPage
    #
    # @usage
    #     instance = TestedPage[<route>]
    def [] route
      @instances[route]
    end

    # Retourne TRUE si la route +route+ existe, c'est-à-dire si elle
    # a déjà été traité
    def exist? route
      @instances.key? route
    end


  end #/ << self
end #/TestedPage
