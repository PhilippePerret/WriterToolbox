# encoding: UTF-8
class TestedUrl

  class << self

    # {Hash} GROSSE TABLE CONTENANT TOUS LES RÉSULTATS
    attr_reader :hroutes

    # {Array} de toutes les routes testées
    attr_reader :routes

    attr_reader :instances

    # Liste des ID des pages (instances TestedUrl) invalides
    # Note : dans leur @errors, on trouve la liste de leurs
    # erreurs.
    #
    # Pour les récupérer en tant qu'instance TestedUrl, on
    # peut utiliser: TestedUrl[<id>]
    #
    attr_reader :invalides

    def base_url
      @base_url ||= online? ? BASE_URL : BASE_URL_LOCAL
    end
    def online?
      TEST_ONLINE
    end

    def init
      @instances = Array.new
      @invalides = Array.new
    end

    # Ajoute une page invalide
    def add_invalide instance
      @invalides << instance.id
    end

    # Ajouter l'instance +instance+ dans la liste des instances
    def << instance
      instance.id = @instances.count
      @instances << instance
    end

    # Retourne l'instance +id+ des instances de TestedUrl
    #
    # @usage
    #     instance = TestedUrl[<id>]
    def [] id
      @instances[id]
    end


  end #/ << self
end #/TestedUrl
