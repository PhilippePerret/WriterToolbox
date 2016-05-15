# encoding: UTF-8
# raise_unless_admin
class Admin
class Taches
class << self

  attr_reader :suivi

  def init_synchro
    # Pour le suivi qui va être affiché
    @suivi = Array::new
    # Pour le rapport complet (contient toutes les tâches)
    @report = {
      hot:  { taches: { local: nil, distant: nil } },
      cold: { taches: { local: nil, distant: nil } }
    }

    # Le fichier des tâches local
    @path_database_loc = ::Admin::table_taches.bdd.path.to_s
    @path_database_loc_cold = ::Admin::table_taches_cold.bdd.path.to_s
    @suivi << "Path de la base = #{@path_database_loc}"
    @suivi << "Path de la base cold = #{@path_database_loc_cold}"
    site.require_module 'remote_file'
    @rfile      = RFile::new(@path_database_loc)
    @rfile_cold = RFile::new(@path_database_loc_cold)

    # Il faut charger le fichier distant, mais en changeant son nom
    # pour qu'il n'écrase pas le fichier local.
    @rfile.distant.downloaded_file_name = "site_hot-distant-prov.db"
    @rfile_cold.distant.downloaded_file_name = "site_cold-distant-prov.db"
    @path_database_prov = @rfile.distant.local_path
    @path_database_cold_prov = @rfile_cold.distant.local_path

    # On downloade la base des tâches locale (en fait, toute la
    # base des données 'hot' et 'cold' du site) en la plaçant dans
    # un fichier autre que le fichier local.
    # SAUF si param(:reload) n'est pas égale à 1
    if param(:reload) == '1' || false == File.exist?(@path_database_prov)
      @suivi << "Rechargement des fichiers distants"
      download_bases_distantes || ( return false )
    else
      @suivi << "! On ne recharge pas le fichier distant."
    end

    return true
  rescue Exception => e
    debug e
    error e.message # => false
  end

  # = main bouton =
  #
  # Synchronise le fichier online et offline
  # Note : Cela est nécessaire car on peut créer des taches en
  # Online comme en Offline et, surtout, les tâches ONLINE servent
  # aux administrateurs mais elles peuvent être
  #
  # Répond au bouton "Synchroniser"
  def synchronize_taches

    # Télécharger le fichier distant (sous sun autre nom pour
    # pouvoir le comparer au fichier local)
    init_synchro || return

    # On va vérifier que la synchronisation est nécessaire
    synchro_required? || return

    # On compare les deux fichiers. Cette méthode n'affiche
    # rien, elle fait juste la comparaison et détermine les
    # modification à faire.
    compare_listes_taches || return

    # On procède à l'ajout et à la modification des tâches
    # dans le fichier local
    add_and_modify_taches || return

    # On upload le fichier des tâches
    @rfile.upload
    @rfile_cold.upload

    # On en a terminé, on peut détruire les fichiers provisoires
    # local, sauf si ne pas détruire a été coché.
    param(:keep => '0') # il faut vraiment le détruire
    remove_databases_prov || return

    @suivi << "=== Opération de synchronisation des tâches exécutée avec succès. ==="

    debug @suivi.join("\n")
  end

  # ---------------------------------------------------------------------

  # Procède à l'ajout et la modification des tâches
  # dans le fichier local
  def add_and_modify_taches

    # On met le suivi dans le débug et on ré-initialise
    # Ceci pour que seules les lignes vraiment utiles
    # apparaissent.
    debug @suivi.join("\n")
    @suivi = Array::new

    [
      [:hot, @table_taches_loc, @table_taches_dis],
      [:cold, @table_taches_loc_cold, @table_taches_dis_cold]
    ].each do |where, tbl_loc, tbl_dis|

      @report[where][:added_taches].each do |tdata|
        # Noter qu'il y a deux types d'ajout :
        # L'ajout avec le même identifiant (lorsque c'est une tâche
        # dont l'identifiant n'existe que dans la table locale) et
        # l'ajout avec identifiant différent (lorsque l'identifiant
        # existe aussi dans la table local).
        tid = tbl_loc.insert(tdata)
        @suivi << "ADD tâche #{where} ##{tid} : #{tdata.inspect}"
      end

      @report[where][:modified_taches].each do |tdata|
        tid = tdata.delete(:id)
        tbl_loc.update(tid, tdata)
        @suivi << "MOD tâche #{where} ##{tid} : #{tdata.inspect}"
      end

      @report[where][:removed_taches].each do |tdata|
        tbl_loc.delete(tdata[:id])
        @suivi << "REM tâche #{where} ##{tdata[:id]}"
      end
    end #/Fin de boucle hot/cold

    @suivi << "(Consulter le débug pour le détail)"
    return true
  end

  # = main =
  #
  # Comparaison des listes de tâches
  #
  # Produit deux choses :
  #   * Renseigne les propriétés :added_taches et
  #     :modified_taches de @report avec les données des
  #     tâches à ajouter et modifier (pour chaque fichier
  #     cold et hot)
  #   * Produit un tableau de l'analyse, qui pourra être
  #     affiché si nécessaire.
  #
  def compare_listes_taches

    # On récupère toutes les tâches
    get_taches

    [:hot, :cold].each do |where|

      tlocs = @report[where][:taches][:local]
      tdiss = @report[where][:taches][:distant]

      @report[where].merge!(
        # Pour mettre la liste des tâches à ajouter
        added_taches:     Array::new,
        # Pour mettre la liste des tâches à modifier
        modified_taches:  Array::new,
        # Pour mettre la liste des tâches à supprimer
        # En fait, ne sert que pour la table :hot locales
        removed_taches:   Array::new
      )

      # ------------------------------------
      # Boucle sur toutes les tâches locales
      # de type `where` (:hot ou :cold)
      # ------------------------------------
      tlocs.each do |tid, tloc|

        tdis = tdiss[tid]

        if tdis != nil
          # Le fichier distant connait cet id de tache
          # C'est la même si elle a été créée en même temps
          if tdis[:created_at] == tloc[:created_at]
            # => C'est la même tache
            # =>  On doit vérifier si des changements ont été faits
            #     et prendre la date de modification pour savoir le
            #     plus récent
            if where == :hot && tdis[:updated_at] == tloc[:updated_at]
              # => Tâche courante strictement identique
            elsif where == :cold && tdis[:ended_at] == tloc[:ended_at]
              # => Tâche en archive strictement identique
            elsif where == :hot && tdis[:updated_at] > tloc[:updated_at]
              # => La tâche distante a été modifiée en dernier
              # => Il faut reporter ses modifications sur la
              #     tache locale.
              @suivi << "Tâche distante ##{tid} modifiée en dernier => prendre ses données."
              @report[where][:modified_taches] << tdis
            else
              # => La tâche locale a été modifiée en dernier, il
              #    n'y a rien à faire.
            end
          else
            # Une tâche inconnue
            @suivi << "La tâche distante ##{tid} de même ID est différente => il faut l'ajouter au fichier local (avec ID différent)."
            # Il faut supprimer l'identifiant pour en obtenir un nouveau
            tdis.delete(:id)
            @report[where][:added_taches] << tdis
          end
        else
          # Le fichier distant ne connait pas cette tache
          #
          # Si on est sur la table :hot, et que cette tache existe
          # dans la table :cold distante, alors il faut détruire cette
          # tâche dans la table :hot locale car c'est une tâche marquée
          # finie sur le site distant
          if where == :hot
            @suivi << "Tâche :hot inconnue dans le fichier distant => Vérifier si elle n'a pas été marquée finie sur le site distant"
            if @report[:cold][:taches][:distant].has_key?(tid)
              @suivi << "La tâche ##{tid} est connue dans la table :cold distante"
              @suivi << "Il faut la détruire localement."
              @report[:hot][:removed_taches] << tloc
            else
              @suivi << "La tâche ##{tid} est inconnue de la table :cold distante"
              @suivi << "=> On ne la détruit pas localement pour qu'elle soit ajoutée sur le site distant"
            end
          end
          # => On doit l'ajouter telle quelle (donc ne rien faire… puisque
          # c'est le fichier local qu'on va ensuite synchroniser online
        end

      end # / Fin de boucle sur toutes les tâches locales

      # ---------------------------------------------------------------------
      # ---------------------------------------------------------------------
      # ---------------------------------------------------------------------

      # Les tâches terminées sur le site distant :
      #   - existent encore dans la table hot locale
      #   - n'existe plus dans la table hot distante
      #   - existent dans la table cold distante
      #   - n'existent pas dans la table cold locale
      # DONC :
      #   Si une tâche existe dans la table hot locale,
      #   mais :
      #     - qu'elle n'existe plus dans la table hot distante
      #     - et qu'elle exite dans la table cold distante
      #     => Il faut LA DÉTRUIRE dans la table hot locale et
      #        L'AJOUTER dans la table cold locale


      # ---------------------------------------
      # Boucle sur toutes les tâches distantes
      # ---------------------------------------
      # Note : seulement celles qui n'appartiennent pas
      # à la base locale (ID inconnu)
      tdiss.each do |tid, tdis|
        # On passe les tâches distantes de même id que des tâches
        # locale.
        next if tlocs.has_key? tid
        # Toutes les autres tâches doivent être ajoutées
        # sauf si c'est la table :hot qui est testée et que
        # la donnée manquante à la table locale se trouve dans
        # la table local cold (ce qui signifie que la tâche a été
        # terminée et mise en archives localement)
        if where == :hot
          if @report[:cold][:taches][:local].has_key?(tid)
            @suivi << "Tache #{where} distante #{tid} non ajoutée car mise en archives."
            next
          end
        end
        @suivi << "Ajout de la tache #{where} distante ##{tid}"
        # Note : Ici, on peut garder le même identifiant pour
        # la tâche puisqu'elle n'existe pas dans le fichier
        # local.
        @report[where][:added_taches] << tdis
      end # / Fin de boucle sur toutes les tâches distantes

    end # /fin boucle hot/cold
    return true
  end

  # Méthodes récupérant les tâches
  def get_taches

    @table_taches_loc = BdD::new(@rfile.path).table('todolist')
    @table_taches_dis = BdD::new(@rfile.distant.local_path).table('todolist')
    @table_taches_loc_cold = BdD::new(@rfile_cold.path).table('todolist')
    @table_taches_dis_cold = BdD::new(@rfile_cold.distant.local_path).table('todolist')

    [
      [:hot,  @table_taches_loc,      @table_taches_dis],
      [:cold, @table_taches_loc_cold, @table_taches_dis_cold]
    ].each do |where, tbl_loc, tbl_dis|
      @report[where][:taches][:local]    = tbl_loc.select()
      @report[where][:taches][:distant]  = tbl_dis.select()
    end
    @suivi << "Récupération des tâches terminée."
    return true
  end

  def download_bases_distantes
    ok = true
    [
      [@rfile, @path_database_prov],
      [@rfile_cold, @path_database_cold_prov]
    ].each do |rf, pathdb|
      rf.download
      ok = ok && File.exist?(pathdb)
      if ok
        @suivi << "Fichier distant downloadé dans #{pathdb}."
      else
        @suivi << "Fichier distant non downloadé (fichier #{pathdb} introuvable…)"
      end
    end
    return ok
  end

  # Détruire le fichier provisoire des tâches downloadé
  def remove_databases_prov
    return if param(:keep) == '1'
    ok = true
    [@path_database_prov, @path_database_cold_prov].each do |pathdb|
      File.unlink(pathdb) if File.exist?(pathdb)
      ok = ( false == File.exist?(pathdb) )
    end
    return ok
  end

  # Retourne TRUE si les deux fichiers comportent des dates différentes
  # en précisant qui est le plus vieux.
  def synchro_required?
    [@rfile, @rfile_cold].each do |rf|
      loc_mtime = rf.mtime
      dis_mtime = rf.distant.mtime
      if loc_mtime < dis_mtime
        @suivi << "La base locale a besoin d'être actualitée (loc:#{loc_mtime}/dis:#{dis_mtime})"
        return true
      elsif dis_mtime < loc_mtime
        @suivi << "La base distante a besoin d'être actualisée (loc:#{loc_mtime}/dis:#{dis_mtime})"
        return true
      else
        @suivi << "Les deux base portent la même date, la synchronisation n'est pas nécessaire."
      end
    end
    return false
  end

end #/ << self
end #/Taches
end #/Admin
