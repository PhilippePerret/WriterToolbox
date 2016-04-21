# encoding: UTF-8
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
    def widget
      (
        menu_types_taches +
        "Tâche…".in_span(id:"span_titre") +
        "admin/add_tache".in_hidden(name:'url') + # pour soumettre le formulaire
        site.current_route.route.in_hidden(name:"tache[current_route]") +
        SiteHtml::Route::last.in_hidden(name:"tache[last_route]") +
        ENV['QUERY_STRING'].in_hidden(name:"tache[query_string]") +
        "".in_hidden(id:'tache_titre_page', name:'tache[titre_page]') + # sera défini par javascript
        "".in_textarea(id:'tache_detail', name:'tache[detail]', placeholder:"Détail (si c'est une erreur typographique par exemple)") +
        "Créer la tâche".in_a(id:"btn_create_tache", onclick:"$.proxy(TachesWidget,'create_tache')()").in_div(class:'right')
      ).in_form(id:"taches_widget")
    end
    def menu_types_taches
      all_taches.collect do |value,title|
        title.in_option(value: value)
      end.join('').in_select(id:"tache_id", name:"tache[id]", size:6)
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
