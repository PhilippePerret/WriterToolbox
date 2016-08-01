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



    # Liste des ID des pages (instances TestedPage) invalides
    # Note : dans leur @errors, on trouve la liste de leurs
    # erreurs.
    #
    # Pour les récupérer en tant qu'instance TestedPage, on
    # peut utiliser: TestedPage[<id>]
    #
    attr_reader :invalides

    def base_url
      @base_url ||= online? ? BASE_URL : BASE_URL_LOCAL
    end
    def online?
      TEST_ONLINE
    end

    def init
      @instances = Hash.new
      @invalides = Array.new
    end

    # Ajoute une page invalide
    # OBSOLÈTE
    # Maintenant, on doit marquer la page testée comme invalide
    # Mais on peut quand même conserver les routes invalides,
    # à la rigueur.
    def add_invalide route
      @invalides << route
    end

    # Ajouter l'instance +instance+ dans la liste des instances
    def << instance
      @instances.merge! instance.route => instance
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
