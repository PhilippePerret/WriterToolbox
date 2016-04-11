# encoding: UTF-8
raise_unless_admin
class Admin
class Taches
class << self

  attr_reader :suivi

  def init_synchro
    # Pour le suivi qui va être affiché
    @suivi = Array::new
    # Pour le rapport complet (contient toutes les tâches)
    @report = Hash::new
    @report = {
      taches: { local: nil, distant: nil }
    }

    # Le fichier des tâches local
    @path_database_loc = ::Admin::table_taches.bdd.path.to_s
    @suivi << "Path de la base = #{@path_database_loc}"
    site.require_module 'remote_file'
    @rfile = RFile::new(@path_database_loc)

    # Il faut charger le fichier distant, mais en changeant son nom
    # pour qu'il n'écrase pas le fichier local.
    @rfile.distant.downloaded_file_name = "site_hot-distant-prov.db"
    @path_database_prov = @rfile.distant.local_path

    # On downloade la base des tâches locale (en fait, toute la
    # base des données 'hot' du site) en la plaçant dans un fichier
    # autre que le fichier local.
    # SAUF si param(:reload) n'est pas égale à 1
    if param(:reload) == '1' || false == File.exist?(@path_database_prov)
      @suivi << "Rechargement du fichier distant"
      download_base_distante || ( return false )
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

    # On en a terminé, on peut détruire le fichier provisoire
    # local, sauf si ne pas détruire a été coché.
    param(:keep => '0') # il faut vraiment le détruire
    remove_database_prov || return

    @suivi << "=== Opération de synchronisation des tâches exécutée avec succès. ==="


  end

  # = main bouton =
  #
  # Compare les deux fichiers de tâche (local et distant) et affiche
  # les différences.
  #
  # Cette méthode répond au bouton "Comparer"
  #
  def compare_fichiers

    # Télécharger le fichier distant (sous sun autre nom pour
    # pouvoir le comparer au fichier local)
    init_synchro || return

    # On compare les deux fichiers. Cette méthode n'affiche
    # rien, elle fait juste la comparaison et détermine les
    # modification à faire.
    compare_listes_taches || return

    # Afficher la difference des deux fichiers
    display_diff_taches || return

    # On en a terminé, on peut détruire le fichier provisoire
    # local, sauf si ne pas détruire a été coché.
    remove_database_prov || return

    @suivi << "\n=== Comparaison des fichiers exécutée avec succès ==="

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

    @report[:added_taches].each do |tdata|
      # Noter qu'il y a deux types d'ajout :
      # L'ajout avec le même identifiant (lorsque c'est une tâche
      # dont l'identifiant n'existe que dans la table locale) et
      # l'ajout avec identifiant différent (lorsque l'identifiant
      # existe aussi dans la table local).
      tid = @table_taches_loc.insert(tdata)
      @suivi << "ADD #{tid} : #{tdata.inspect}"
      @suivi << "MOD ##{tid} : #{tdata.inspect}"
    end
    @report[:modified_taches].each do |tdata|
      tid = tdata.delete(:id)
      @table_taches_loc.update(tid, tdata)
      @suivi << "MOD ##{tid} : #{tdata.inspect}"
    end

    @suivi << "(Consulter le débug pour le détail)"
    return true
  end

  # Définit le suivi pour qu'il affiche la différence entre
  # les deux fichiers
  def display_diff_taches

    compare_listes_taches || return

    @tab << "\n\n"

    # On met le suivi dans le débug et on le remplace par
    # le tableau
    debug @suivi.join("\n")
    @suivi = @tab

  end

  # = main =
  #
  # Comparaison des listes de tâches
  #
  # Produit deux choses :
  #   * Renseigne les propriétés :added_taches et
  #     :modified_taches de @report avec les données des
  #     tâches à ajouter et modifier
  #   * Produit un tableau de l'analyse, qui pourra être
  #     affiché si nécessaire.
  #
  # Construit l'affiche de la différence entre les
  # deux fichiers.
  #
  # Cette méthode produit un tableau qui va être placé
  # dans le suivi pour être affiché ensuite.
  def compare_listes_taches

    # On récupère toutes les tâches
    get_taches

    tlocs = @report[:taches][:local]
    tdiss = @report[:taches][:distant]

    @report.merge!(
      # Pour mettre la liste des tâches à ajouter
      added_taches:     Array::new,
      # Pour mettre la liste des tâches à modifier
      modified_taches:  Array::new
    )

    # Tache / échéance / admin_id
    @tab = Array::new

    @tab << "\n#{tabrow_delimitor}"
    @tab << tabrow(" ", "TÂCHES LOCALES", "TÂCHES DISTANTES")
    @tab << tabrow_delimitor
    @tab << tabrow("Nombre tâches", tlocs.count, tdiss.count )
    @tab << "POUR_ADDED"
    @tab << "POUR_MODIFIED"
    @tab << tabrow_delimitor
    @tab << tabrow(" ", "admin state échéance", "admin state échéance")
    @tab << tabrow_delimitor

    # ------------------------------------
    # Boucle sur toutes les tâches locales
    # ------------------------------------
    tlocs.each do |tid, tloc|

      tdis = tdiss[tid]

      data_row = {
        titre: nil,
        cloc: nil,
        cdis: nil
      }

      # Pour la rangée de données
      data_loc = "#{tloc[:admin_id].to_s.ljust(5)}  #{tloc[:state]}  #{echeance tloc}"
      unless tdis.nil?
        data_dis = "#{tdis[:admin_id].to_s.ljust(5)}  #{tdis[:state]}  #{echeance tdis}"
      else
        data_dis = nil
      end

      data_row[:titre] = "Tâche ID ##{tid}"
      data_row[:cloc]  = data_loc

      if tdis != nil
        data_row[:cdis] = "Exist"
        # Le fichier distant connait cet id de tache
        # C'est la même si elle a été créée en même temps
        if tdis[:created_at] == tloc[:created_at]
          # => C'est la même tache
          # =>  On doit vérifier si des changements ont été faits
          #     et prendre la date de modification pour savoir le
          #     plus récent
          data_row[:cdis] << " - Même tâche"
          if tdis[:updated_at] == tloc[:updated_at]
            # => Tâche strictement identique
            data_dis = nil
          elsif tdis[:updated_at] > tloc[:updated_at]
            # => La tâche distante a été modifiée en dernier
            # => Il faut reporter ses modifications sur la
            #     tache locale.
            @suivi << "Tâche distante ##{tid} modifiée en dernier => prendre ses données."
            @report[:modified_taches] << tdis
          else
            # => La tâche locale a été modifiée en dernier, il
            #    n'y a rien à faire.
            data_dis = "Données anciennes"
          end
        else
          # => C'est une autre tâche (ajoutée en ONLINE)
          # => Il faut l'ajouter au fichier local
          @suivi << "La tâche distante ##{tid} de même ID est différente => il faut l'ajouter au fichier local (avec ID différent)."
          data_row[:cdis] << " - AUTRE => ADD"
          # Il faut supprimer l'identifiant pour en obtenir un nouveau
          tdis.delete(:id)
          @report[:added_taches] << tdis
        end
      else
        # Le fichier distant ne connait pas cette tache
        # => On doit l'ajouter telle quelle (donc ne rien faire… puisque
        # c'est le fichier local qu'on va ensuite synchroniser online
        data_row[:cdis] = "Unknown"
      end

      # La rangée de comparaison
      @tab << tabrow(data_row)
      # La rangée de données distante
      @tab << tabrow("", "", data_dis) unless data_dis.nil?
    end # / Fin de boucle sur toutes les tâches

    # ---------------------------------------------------------------------
    # ---------------------------------------------------------------------
    # ---------------------------------------------------------------------

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
      @suivi << "Ajout de la tache distante ##{tid}"
      # Note : Ici, on peut garder le même identifiant pour
      # la tâche puisqu'elle n'existe pas dans le fichier
      # local.
      @report[:added_taches] << tdis
      data_dis = "#{tdis[:admin_id].to_s.ljust(5)}  #{tdis[:state]}  #{echeance tdis}"
      data_row = {
        titre: "Tâche distante ##{tid}",
        cloc: "",
        cdis: "#{data_dis} ADD"
      }
      # La rangée de comparaison
      @tab << tabrow(data_row)
    end # / Fin de boucle sur toutes les tâches distantes

    # On indique dans le tableau le nombre d'ajouts et de
    # modifications à faire.
    add_offset = @tab.index("POUR_ADDED")
    mod_offset = @tab.index("POUR_MODIFIED")
    @tab[add_offset] = tabrow("Ajouts", @report[:added_taches].count, "")
    @tab[mod_offset] = tabrow("Modifications", @report[:modified_taches].count, "")

    return true
  end

  # Méthodes récupérant les tâches
  def get_taches
    @table_taches_loc = BdD::new(@rfile.path).table('todolist')
    @table_taches_dis = BdD::new(@rfile.distant.local_path).table('todolist')

    taches_loc = @table_taches_loc.select()
    taches_dis = @table_taches_dis.select()

    # Modifier l'admin_id 253 => 3 (ancien ID de Marion)
    taches_loc.each do |tid, tdata|
      tdata[:admin_id] = 3 if tdata[:admin_id] == 253
    end
    taches_dis.each do |tid, tdata|
      tdata[:admin_id] = 3 if tdata[:admin_id] == 253
    end

    @report[:taches][:local]    = taches_loc
    @report[:taches][:distant]  = taches_dis


    @suivi << "Comparaison des listes de tâches opérées."
    return true
  end

  def download_base_distante
    @rfile.download
    ok = File.exist?(@path_database_prov)
    if ok
      @suivi << "Fichier distant downloadé dans #{@path_database_prov}."
    else
      @suivi << "Fichier distant non downloadé (fichier #{@path_database_prov} introuvable…)"
    end
    return ok
  end

  # Détruire le fichier provisoire des tâches downloadé
  def remove_database_prov
    return if param(:keep) == '1'
    File.unlink(@path_database_prov) if File.exist?(@path_database_prov)
    return false == File.exist?(@path_database_prov)
  end

  # Retourne TRUE si les deux fichiers comportent des dates différentes
  # en précisant qui est le plus vieux.
  def synchro_required?
    loc_mtime = @rfile.mtime
    dis_mtime = @rfile.distant.mtime
    if loc_mtime < dis_mtime
      @suivi << "La base locale a besoin d'être actualitée (loc:#{loc_mtime}/dis:#{dis_mtime})"
    elsif dis_mtime < loc_mtime
      @suivi << "La base distante a besoin d'être actualisée (loc:#{loc_mtime}/dis:#{dis_mtime})"
    else
      @suivi << "Les deux base portent la même date, la synchronisation n'est pas nécessaire."
      return false
    end
    return true
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'affichage
  # ---------------------------------------------------------------------
  COL_TITRE_WIDTH = 20
  COL_TACHE_WIDTH = 30
  # Construit une rangée
  def tabrow titre, clocal = nil, cdistant = nil
    if titre.instance_of?(Hash)
      cdistant  = titre[:cdis]
      clocal    = titre[:cloc]
      titre     = titre[:titre]
    end
    "| #{colonne_titre titre} | #{colonne_locale clocal} | #{colonne_distante cdistant} |"
  end
  # Construit un déliminteur
  def tabrow_delimitor
    @tabrow_delimitor ||= "-" * (COL_TITRE_WIDTH + 2*COL_TACHE_WIDTH + 3*3 + 1)
  end
  # Ajoute un texte à la colonne titre
  def colonne_titre str
    str.to_s.ljust(COL_TITRE_WIDTH)
  end
  # Ajoute un élément à la colonne locale
  def colonne_locale str
    str.to_s.ljust(COL_TACHE_WIDTH)
  end
  # Ajoute un élément à la colonne distante
  def colonne_distante str
    str.to_s.ljust(COL_TACHE_WIDTH)
  end

  def echeance hdata
    return "---" if hdata[:echeance].nil?
    Time.at(hdata[:echeance]).strftime("%d/%m/%y")
  end
  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Retourne le suivi à afficher, s'il est défini
  #
  # Noter que la méthode est toujours appelée, même lorsque
  # aucune opération n'est demandée.
  def display_suivi
    if suivi.nil?
      <<-HTML
Cette section permet de synchroniser la liste des tâches locales et distantes,
entendu qu'on peut modifier cette liste online ou offline.

Le bouton “Comparer” permet de simplement comparer les deux fichiers et
d'afficher les différences tandis que le bouton “Synchroniser” procède à la
synchronisation proprement dite.

La synchronisation consiste en:

* Download du fichier site_hot.db,
* Comparaison des deux tables `todolist`,
* Ajout au fichier local des tâches n'existant que sur le fichier
  distant,
* Modification dans le fichier local des tâches modifiées dans le
  fichier distant,
* Upload du fichier local pour synchronisation.
      HTML
    else
      suivi.join("\n")
    end
  end

end #/ << self
end #/Taches
end #/Admin
