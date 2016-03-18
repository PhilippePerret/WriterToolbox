# encoding: UTF-8
=begin
Méthodes pour les taches
=end
class SiteHtml
class Admin
class Console

  class Taches
  class << self
    def sub_log str; console.sub_log str end

    # Marquer une tache finie
    def marquer_tache_finie tache_id
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      itask = ::Admin::Todolist::Tache::new(tache_id.to_i)
      mess = if itask.exist?
        if itask.ended?
          "La tache #{tache_id} est déjà terminée."
        else
          itask.stop
          "Tache #{tache_id} marquée terminée."
        end
      else
        "La tache #{tache_id} n'existe pas."
      end
      return "#{mess}\n# (taper `list taches` pour voir la liste des taches)."
    end

    def detruire_tache tache_id
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      itask = ::Admin::Todolist::Tache::new(tache_id.to_i)
      mess = if itask.exist?
        itask.destroy
        "Tache #{tache_id} détruite avec succès."
      else
        "La tache #{tache_id} n'existe pas."
      end
      return "#{mess}\n# (taper `list taches` pour voir la liste des taches)."
    end
    # Créer un nouvelle tache en partant des données string
    # +data_str+ envoyées en argument
    def create_tache data_str
      flash "Création de la tache `#{data_str}`"
      return ""
    end

    # Affiche la liste de taches
    # +options+
    #   :all  Si true => toutes les taches même les taches achevées
    def show_liste_taches options = nil
      options ||= Hash::new
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      task_list = if options[:all]
        sub_log "liste de toutes les taches".in_h3
        ::Admin::table_taches.select(order: "echeance DESC", colonnes:[]).keys.collect do |tid|
          ::Admin::Todolist::Tache::new(tid)
        end
      else
        sub_log "liste des taches en cours".in_h3
        ::Admin::Todolist::new().taches
      end
      lt = task_list.collect do |itask|
        owner     = itask.admin.pseudo
        echeance  = Time.at(itask.echeance).strftime("%d/%m/%y")
        (
          "##{itask.id} #{itask.tache} (#{owner} - #{echeance})"
        ).in_li
      end.join.in_ul(class:'tdm')
      sub_log lt
      return ""
    end

    # Synchronise les deux fichiers taches local et distant en
    # prenant le plus vieux comme référence.
    def synchronise

    end

  end # << SELF
  end #/Taches
end #/Console
end #/Admin
end #/SiteHtml
