# encoding: UTF-8

# Pour permettre à Marshal de dumper les instances TestedPage,
# en attendant que Nokogiri implémente ces méthodes
class Nokogiri::HTML::Document; def _dump_data; nil end end
class Nokogiri::XML::Element; def _dump_data; nil end end
class Nokogiri::XML::Text; def _dump_data; nil end end

class TestedPage
  class << self
    # Temps de démarrage et de fin de l'opération d'analyse
    attr_reader :start_time, :end_time

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

    # Nombre de routes exclues par EXCLUDED_ROUTES
    attr_accessor :routes_exclues_count

    # Compte total de liens. On pourrait les compter dans les instances,
    # mais c'est pour avoir un rapport plus rapide.
    attr_accessor :links_count

    # Méthode qui sauve toutes les données récoltées, après
    # analyse de toutes les pages et merge des routes similaires.
    #
    # Cela permet de repartir de cette base-là dans le cas
    # où on travaille sur le rapport produit.
    def save_data_in_marshal
      File.unlink path_marshal if File.exist? path_marshal
      # Comme certaines class n'implémentent pas la méthode _dump_data
      # qui perrmet de dumper les data, il faut les mettre à nil
      # Table qui va être enregistrée
      data = {
        instances:    instances,
        invalides:    invalides,
        links_count:  links_count
      }
      File.open(path_marshal,'wb'){|f| Marshal.dump(data)}
    rescue Exception => e
      debug "# Impossible de dumper les données au format Marshal : #{e.message}"
      File.unlink path_marshal if File.exist? path_marshal
    end

    # Récupérer les dernières données du fichier Marshal
    #
    # Retourne TRUE si on a pu récupérer les données, FALSE dans le
    # cas contraire, ce qui entrainera l'analyse de force.
    def get_data_from_marshal
      if File.exist? path_marshal
        data = File.open(path_marshal,'rb'){|f| Marshal.load(f.read)}
        @instances    = data[:instances]
        @invalides    = data[:invalides]
        @links_count  = data[:links_count]
        return true
      else
        debug "Le fichier marshal (#{path_marshal}) n'existe pas. Impossible de récupérer les données."
        return false
      end
    rescue Exception => e
      debug "# Impossible de récupérer les données du fichier Marshal : #{e.message}"
      return false
    end

    def path_marshal
      @path_marshal ||= File.join(MAIN_FOLDER, 'output', 'marshal_data.msh')
    end

  end #/ << self
end #/TestedPage
