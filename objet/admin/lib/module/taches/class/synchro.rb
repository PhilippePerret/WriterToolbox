# encoding: UTF-8
raise_unless_admin
=begin

Ce module inaugure le système de synchro de table MySQL à table MySQL.

=end
class Admin
class Taches
class << self

  attr_reader :suivi

  # = main bouton =
  #
  # Synchronise la table locale et la table distant des
  # tâche (note : maintenant, elles sont en mySQL)
  #
  # Note : Cela est nécessaire car on peut créer des taches en
  # Online comme en Offline et, surtout, les tâches ONLINE servent
  # aux administrateurs mais elles peuvent être
  #
  # Répond au bouton "Synchroniser"
  def synchronize_taches
    init_synchro || return
    # SYNCHRONISATION des deux tables, locale et distante.
    synchronize_tables_taches || return
    # debug @suivi.join("\n")
  end

  # Initialisation de la synchro
  #
  def init_synchro

    # Pour le suivi qui va être affiché
    @suivi = Array::new
    # Pour le rapport complet (contient toutes les tâches)
    @report = {
      hot:  { taches: { local: nil, distant: nil } },
      cold: { taches: { local: nil, distant: nil } }
    }
    # Récupération des deux listes de tâches locales
    # et distantes, mais seulement les HOT
    get_taches
    return true
  rescue Exception => e
    debug e
    error e.message # => false
  end


  # ---------------------------------------------------------------------

  # = main =
  #
  # Synchronise la table des tâches locale avec la table
  # des tâches distantes.
  #
  # Rappel : les deux tables sont en MySQL.
  #
  def synchronize_tables_taches

    # À présent, on ne traite que la table des tâches
    # courantes. Elles peuvent avoir été ajoutées en local commme
    # en distant.
    #
    # Si une tâche se trouve en local mais pas en distant :
    #   => Regarder si elle existe dans la table cold DISTANTE
    #      Rappel : ça se fait par la date de création, car l'id
    #      peut avoir été modifié.
    #   SI NON :
    #   - c'est une nouvelle tâche (local)
    #     => Il faut l'ajouter en distant
    #   SI OUI
    #   - elle a été finie en distant
    #     => Il faut la finir en local
    #
    # Si une tâche se trouve en distant mais pas en local
    #   => Regarder si elle existe dans la table cold LOCALE
    #      Rappel : ça se fait par la date de création, car l'id
    #      peut avoir été modifié.
    #   SI OUI (elle existe dans la table cold)
    #     - c'est une tâche finie en local
    #       => il faut la finir en distant
    #   SI NON (elle n'existe pas dans la table cold)
    #     - c'est une nouvelle tâche (distante)
    #       => il faut l'ajouter en locale

    # Pour ne faire que la simulation
    # Aucune modification ne sera faite, les opérations seront
    # affichées dans le débug
    #
    @simulation = false

    if @simulation
      debug "\n\n\n==== SIMULTATION SYNCHRONISATION DES TACHES ===\n\n"
    end

    taches_hot_loc = @report[:hot][:taches][:local]
    taches_hot_dis = @report[:hot][:taches][:distant]


    ids_taches_dis_traited = []

    if @simulation
      debug "* Traitement des tâches locales"
      debug "  #{taches_hot_loc.count} tâches hot locales"
      debug "  #{taches_hot_dis.count} tâches hot distantes"
    end

    # Boucle sur toutes les tâches locales
    taches_hot_loc.each do |ctime_tache, dtache|

      dtache_sans_id = dtache.dup
      tid = dtache_sans_id.delete(:id)

      if @simulation
        debug "\n* Traitement : ##{ctime_tache} : #{dtache.inspect}"
      end

      # Pour que la tâche distante et locale soit identique,
      # il faut 1/ qu'elles aient le même identifiant et
      # 2/ qu'elles aient la même date de création
      if taches_hot_dis.key?(ctime_tache)
        ids_taches_dis_traited << ctime_tache
        # Si les données sont identiques, on peut s'arrêter là
        next if taches_hot_dis[ctime_tache] == dtache
        # Sinon il faut actualiser la plus vieille
        tdis = taches_hot_dis[ctime_tache]
        tdis_id = tdis.delete(:id)
        tloc = dtache
        tloc_id = tloc.delete(:id)
        if tdis[:updated_at] > tloc[:updated_at]
          if @simulation
            debug "UPDATE HOT LOCALE : ##{tloc_id} -> #{tdis.inspect}"
          else
            @table_hot_loc.update( tloc_id, tdis )
          end
        else
          if @simulation
            debug "UPDATE HOT DISTANT : ##{tdis_id} -> #{tloc.inspect}"
          else
            @table_hot_dis.update( tdis_id, tloc )
          end
        end
      else
        # La table distante hot ne connait pas cette tache
        # La tache existe-t-elle dans la table cold distante
        if @table_cold_dis.count(where: "created_at = #{ctime_tache} ") > 0
          # OUI, elle existe => Tache finie en distant
          # => La finir en local
          if @simulation
            debug "FINIR ##{ctime_tache} EN LOCAL"
          else
            @table_cold_loc.insert(dtache_sans_id)
            @table_hot_loc.delete(tid)
          end
        else
          # NON, elle n'existe pas => Nouvelle tache locale
          # => L'ajouter en hot distant
          if @simulation
            debug "AJOUT DISTANT : #{dtache.merge(id: tid).inspect}"
          else
            @table_hot_dis.insert( dtache_sans_id )
          end
        end
      end
    end #/fin boucle sur les tâches hot locales

    debug "\n\n* Traitement des tâches distantes"

    # Boucle sur les tâches hot distantes qui restent
    taches_hot_dis.each do |ctime_tache, dtache|
      # On passe les tâches distantes déjà traitées en
      # local.
      next if ids_taches_dis_traited.include?(ctime_tache)


      tid = dtache.delete(:id)

      # La table locale hot ne connait pas cette tache
      # La tache existe-t-elle dans la table cold locale
      if @table_cold_loc.count(where: "created_at = #{ctime_tache} ") > 0
        # OUI, elle existe => Tache finie en local
        # => La finir en distant
        if @simulation
          debug "FINIR ##{ctime_tache} DISTANTE"
        else
          @table_cold_dis.insert( dtache)
          @table_hot_dis.delete( tid )
        end
      else
        # NON, elle n'existe pas => Nouvelle tache distante
        # => L'ajouter en hot local
        if @simulation
          debug "AJOUT LOCAL : #{dtache.inspect}"
        else
          @table_hot_loc.insert( dtache )
        end
      end
    end #/fin boucle sur les tâches hot distantes

    if @simulation
      debug "\n\n\n==== /FIN SIMULTATION SYNCHRONISATION DES TACHES ==="
    end

    return true
  end

  # Méthodes récupérant les tâches
  def get_taches

    # La table hot offline
    @table_hot_loc  = site.dbm_table(:hot, 'taches', false)
    # La table hot online
    @table_hot_dis  = site.dbm_table(:hot, 'taches', true)
    # La table cold offline
    @table_cold_loc = site.dbm_table(:cold, 'taches', false)
    # La table cold online
    @table_cold_dis = site.dbm_table(:cold, 'taches', true)

    # On transforme les listes en hash avec en clé
    # LA DATE DE CRÉATION de la tâche pour les reconnaitre
    # plus vite.
    #
    # NOTER QU'IL S'AGIT BIEN DE LA DATE DE CRÉATION EN
    # CLÉ.
    #
    locales = {}
    @table_hot_loc.select.each do |dtache|
      locales.merge! dtache[:created_at] => dtache
    end
    distantes = {}
    @table_hot_dis.select.each do |dtache|
      distantes.merge! dtache[:created_at] => dtache
    end

    # Maintenant, on ne charge que les tâches HOT
    @report[:hot][:taches][:local]    = locales
    @report[:hot][:taches][:distant]  = distantes

    return true
  end

  # Retourne TRUE si la synchro des taches est nécessaire
  # On le fait toujours, ça ne manque pas de pain.
  def synchro_required?
    return true
  end

end #/ << self
end #/Taches
end #/Admin
