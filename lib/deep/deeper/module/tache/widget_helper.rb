# encoding: utf-8
=begin

Pour les méthodes d'helper du widget des tâches

=end
class Admin
class Taches
  class << self

    # {Array} Pour ajouter des tâches à la volée
    # @usage
    #   Dans la page, mettre :
    #     ::Admin::Taches::taches_propres = [
    #       ["valeur", "Titre tache"[, "Texte de la tâche à écrire"]],
    #       ["valeur", "Titre tache"[, "Texte de la tâche à écrire"]],
    #       etc.
    #     ]
    attr_accessor :taches_propres


    # = main =
    #
    # Retourne le "gadget" à insérer dans la page
    #
    # Ce widget se présente comme un petit rectangle qui s'ouvre,
    # quand on passe la souris dessus, affichant une liste de différentes
    # tâche à choisir, comme corriger un bug ou lire par le lecteur.
    # 
    def widget
      (
        "Tâche…".in_span(id:"span_titre") +
        (
          hidden_informations +
          menu_types_taches +
          menu_importance +
          textarea_detail +
          bouton_to_create_tache
        ).in_div(id: 'inner_widget')
      ).in_form(id:"taches_widget")
    end

    # ------------------------------------------------------------
    # CONSTRUCTION DES ÉLÉMENTS
    # ------------------------------------------------------------

    # Champs hidden pour les informations cachées, l'url pour ajax, la
    # route courante, etc.
    def hidden_informations
      hi = String.new
      # Pour qu'ajax sache quelle route emprunter pour traiter l'enregistrement
      # du widget
      hi << "admin/add_tache".in_hidden(name:'url')
      # Pour connaitre la route courante, pour savoir quelle page touche
      # la tâche créée
      cr =
        case site.current_route
        when nil then ""
        else site.current_route.route
        end
      hi << cr.in_hidden(name: "tache[current_route]")
      # Il peut être pertinent de connaitre le REFERER de la page courante
      hi << SiteHtml::Route::last.in_hidden(name:"tache[last_route]")
      # On conserve le query-string car il est une information indispensable
      # quand on se trouve dans un contexte donné ou avec des variables
      # données (même si c'est rare)
      hi << ENV['QUERY_STRING'].in_hidden(name:"tache[query_string]")
      # On mettre dans cette variable le titre de la page, pour une information
      # plus "humaine"
      hi <<  "".in_hidden(id:'tache_titre_page', name:'tache[titre_page]')
      return hi
    end
    # Le bouton pour créer la tâche
    def bouton_to_create_tache
      "Créer la tâche".in_a(
        id: "btn_create_tache",
        onclick: "$.proxy(TachesWidget,'create_tache')()"
      ).in_div(class: 'right')
    end
    
    # Un champ de saisie pour ajouter des détails à propos de la tâche, pour préciser
    # par exemple un bug.
    def textarea_detail
      "".in_textarea(
        id:'tache_detail', name:'tache[detail]', placeholder:"Détail (si c'est une erreur typographique par exemple)"
      )
    end

    # Un menu pour définir l'importance de la tâche
    def menu_importance
      [
        ['3', 'normale'],
        ['5', 'importante'],
        ['7', 'prioritaire']
      ].in_select(id: 'tache_importance', name: 'tache[importance]')
    end
    def menu_types_taches
      all_taches.collect do |value,title|
        title.in_option(value: value)
      end.join('').in_select(id:"tache_id", name:"tache[id]")
    end

    def all_taches
      (taches_propres || Array::new) + taches_default
    end

    # Liste des tâches
    # Une page particulièrement peut en ajouter à la volée
    def taches_default
      @taches_default ||= begin
        DATA_TACHES_TYPE.collect do |tid, tdata|
          [tid, tdata[:hname]]
        end
      end
    end

  end # << self Admin::Taches
end #/Taches
end #/Admin
