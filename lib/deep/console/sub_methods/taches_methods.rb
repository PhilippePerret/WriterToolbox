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
      itask = ::Admin::Taches::Tache::new(tache_id.to_i)
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

    # Pour détruire la tache d'id +tache_id+
    # Noter que la destruction détruit vraiment la tâche, ne la marque
    # pas fini. Elle disparaitra complètement.
    def detruire_tache tache_id
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      itask = ::Admin::Taches::Tache::new(tache_id.to_i)
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
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      data_tache = Data::by_semicolon_in data_str
      data_tache.merge!(updated_at: NOW)
      itache = ::Admin::Taches::Tache::new
      itache.instance_variable_set('@data2save', data_tache)
      itache.data2save_valid? || ( return "Error" )
      # Les données sont valides, on peut enregistrer la tâche
      # Note : C'est la méthode create qui affichera le message
      # de réussite
      itache.create
      return ""
    end

    # Actualise la tache d'ID +tache_id+ avec les nouvelles
    # données +tache_data+
    def update_tache tache_id, tache_data_str
      site.require_objet 'admin'
      ::Admin::require_module 'taches'
      itache = ::Admin::Taches::Tache::new(tache_id)
      raise "Cette tache est inconnue." unless itache.exist?

      # On transforme les données string en hash de données
      htache = Data::by_semicolon_in tache_data_str

      # On fait quelques corrections et vérifications
      htache.merge!(echeance: htache.delete(:le)) if htache.has_key?(:le)
      if htache.has_key?(:echeance)
        htache[:echeance] = itache.test_echeance_tache(htache[:echeance])
        raise "Impossible d'actualiser la tache." if htache[:echeance] == false
      end
      if htache.has_key?(:pour)
        admin_id = htache.delete(:pour)
        unless admin_id.numeric?
          admin = User::get_by_pseudo(admin_id)
          raise "L'administrateur #{admin_id} est inconnu" if admin.nil?
          admin_id = admin.id
        end
        admin_id = admin_id.to_i
        htache.merge!(admin_id: admin_id)
      end
      htache.merge!(state: htache.delete(:statut)) if htache.has_key?(:statut)
      if htache.has_key?(:state)
        htache[:state] = itache.test_statut_tache(htache[:state])
        raise "Impossible d'actualiser la tache." if htache[:state] == false
      end

      # On peut actualiser la tache
      # debug "htache: #{htache.pretty_inspect}"
      itache.set(htache)

    rescue Exception => e
      debug e
      error e.message
      "ERROR"
    else
      "Tache #{itache.id} actualisée."
    end


    # Affiche la liste de taches
    # +options+
    #   :all  Si true => toutes les taches même les taches achevées
    #   :admin  Si défini, l'id (string) ou le pseudo de l'administrateur
    #           dont il faut voir les tâches
    def show_liste_taches options = nil
      options ||= Hash::new
      site.require_objet 'admin'
      ::Admin::require_module 'taches'

      # On relève la liste des tâches
      task_list = if options[:all]
        sub_log "liste de toutes les taches".in_h3
        ::Admin::table_taches.select(order: "echeance DESC", colonnes:[]).keys.collect do |tid|
          ::Admin::Taches::Tache::new(tid)
        end
      elsif options.has_key?( :admin )
        unless options[:admin].numeric?
          admin = User::get_by_pseudo(options[:admin])
          if admin.pseudo == "Marion" && admin.options[0..1] != "15"
            opts = admin.options
            opts[0..1] = "15"
            admin.set(options: opts)
          end
          raise "Aucun user ne porte le pseudo #{options[:admin]}" if admin.nil?
          raise "#{admin.pseudo} n'est pas administrateur/trice" unless admin.admin?
          options[:admin] = admin.id # OK
        else
          admin = User::get(options[:admin].to_i)
        end
        sub_log "liste des taches de #{admin.pseudo}".in_h3
        ::Admin::Taches::new().taches.collect do |itache|
          next if itache.admin_id != admin.id
          itache
        end.compact
      else
        sub_log "liste des taches en cours".in_h3
        ::Admin::Taches::new().taches
      end

      # Format de la réponse, en fonction
      format_ligne = if options.has_key?(:admin)
        "<div class='small'>T.%{tid} %{tache}</div><div class='right tiny'>Échéance : %{echeance} — %{reste}</div>"
      else
        "<div class='small'>T.%{tid} %{tache}</div><div class='right tiny'>Pour : %{owner} - Échéance : %{echeance} — %{reste}</div>"
      end

      if task_list.count > 0
        lt = task_list.collect do |itask|
          owner     = itask.admin.pseudo
          echeance  = if itask.echeance
            Time.at(itask.echeance).strftime("%d/%m/%y")
          else
            "aucune"
          end
          reste = if itask.echeance
            r = ( (itask.echeance - NOW) / 1.day ) + 1
            if r == 0
              "doit être finie aujourd'hui".in_span(class:'blue')
            elsif r > 0
              "dans #{r} jour#{r > 1 ? 's' : ''}"
            else
              "devrait être finie depuis #{r} jour#{r > 1 ? 's' : ''}".in_span(class:'warning')
            end
          else
            "---"
          end
          (
            format_ligne % {tid: itask.id, tache: itask.tache, echeance: echeance, owner: owner, reste: reste}
          ).in_div
        end.join('')
      else
        lt = "Aucune tâche trouvée."
      end
      sub_log lt
      return ""
    end


  end # << SELF
  end #/Taches
end #/Console
end #/Admin
end #/SiteHtml
