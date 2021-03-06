# encoding: UTF-8
=begin

  Module de synchronisation de la collection Narration.
  Cette synchronisation joue sur deux choses :
    - les données de la base `boite-a-outils_cnarration`
    - les fichiers physiques des livres

=end
class Sync

  def synchronize_narration
    @report << "* Synchronisation IMMÉDIATE de la Collection NARRATION"
    if Sync::CNarration.instance.synchronize(self)
      @suivi << "= Synchronisation de la collection Narration OPÉRÉE AVEC SUCCÈS"
    else
      @report << "# PROBLÈME AVEC LA SYNCHRONISATION DE LA COLLECTION NARRATION".in_span(class: 'red')
    end
  end

class CNarration
  include Singleton
  include CommonSyncMethods

  # = main =
  #
  # Méthode principale de la synchronisation de la collection Narration.
  # - au niveau de la base de données
  # - au niveau des fichiers à synchroniser
  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0

    # Syncrhonisation des données des pages et
    # chapitre/sous-chapitre de la collection
    synchronize_database

    # Synchronisation des données de tables des
    # matières de la collection narration
    nb_sync = Sync::TDMNarration.instance.synchronize(sync)
    @nombre_synchronisations += nb_sync

    # Synchronisation des fichiers physiques de la
    # collection.
    synchronize_fichiers

    if @nombre_synchronisations > 0
      report "  NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class:'blue bold')
      report '  = Synchronisation de la collection Narration OPÉRÉE AVEC SUCCÈS'.in_span(class:'blue bold')
    end
  rescue Exception => e
    debug e
    self.error "# PROBLÈME SYNCHRO NARRATION : #{e.message}"
    false
  else
    true
  end

  def synchronize_database

    report "* Synchronisation des données de database"
    report "Nombre de rangées locales   : #{loc_rows.count}"
    report "Nombre de rangées distantes : #{dis_rows.count}"

    # Boucle sur chaque donnée de page distante.
    # Puisque les pages de la collection ne peuvent se créer et se
    # détruire que localement, toute rangée de la table distante qui
    # n'existe pas en local est une page détruite et qu'il faut détruire
    # en distant.
    dis_rows.each do |pid, dis_data|
      loc_data = loc_rows[pid]
      loc_data.nil? || next
      dis_table.delete(pid)
      report "DESTRUCTION de la rangée de la page distante ##{pid} (“#{dis_data[:titre]}”)"
    end

    # Boucle sur chaque donnée de page locale qui doit être actualisée
    # ou créée en distante.
    #
    loc_rows.each do |pid, loc_data|
      dis_data = dis_rows[pid]

      # debug "loc_data: #{loc_data.inspect}"
      # debug "dis_data: #{dis_data.inspect}"

      if dis_data.nil?
        # C'est la création d'une nouvelle page en local
        # ======== ACTUALISATION =======
        dis_table.insert(loc_data)
        @nombre_synchronisations += 1
        # ==============================
        report "CRÉATION de la page (ou titre) DISTANT : #{loc_data.inspect}"
      elsif loc_data != dis_data
        # Données différentes
        # Autre donnée différente. Dans ce cas, on prend
        # la date de dernière modification pour savoir quelle
        # donnée doit être actualisée
        if loc_data[:updated_at] != dis_data[:updated_at]
          if loc_data[:updated_at] > dis_data[:updated_at]
            # Actualisation de la donnée distante
            dis_table.update(pid, loc_data)
            @nombre_synchronisations += 1
            report "Actualisation de la donnée DISTANTE de la page ##{pid}"
          else
            # Actualisation de la donnée LOCALE
            loc_table.update(pid, dis_data)
            @nombre_synchronisations += 1
            report "Actualisation de la donnée LOCALE de la page ##{pid}"
          end
        end
      else
        suivi "Pages ##{pid} loc/dis identiques"
      end
    end
  end

  def synchronize_fichiers
    report "* Synchronisation des fichiers physiques"
    sync_files loc_cnarration_folder, dis_cnarration_folder
    report "  - Synchronisation des pages dynamiques OK"
    # TODO Lorsque le connection sera bonne à nouveau on pourra aussi
    # synchroniser les fichiers bruts de travail (md)
    nb = detruire_fichiers_backup
    report "  - Destruction des fichiers .backup de construction OK (#{nb})"
    sync_files loc_cnarration_raw_folder, dis_cnarration_raw_folder
    report "  - Synchronisation des pages brutes de travail OK"
    report "= Synchronisation des fichiers physiques OK"
  end

  # ---------------------------------------------------------------------
  #   SOUS-MÉTHODES DE SYNCHRONISATION
  # ---------------------------------------------------------------------

  # # Actualisation d'un fichier ERB distant
  # #
  # def upload_narration_file relpath
  #   loc_fullpath = "#{loc_cnarration_folder}/#{relpath}"
  #   dis_fullpath = "#{dis_cnarration_folder}/#{relpath}"
  #   retour = upload_file loc_fullpath, dis_fullpath
  # end

  def detruire_fichiers_backup
    Dir["#{loc_cnarration_raw_folder}/**/*.backup"].each{|f|File.unlink(f)}.count
  end

  # Dossier narration local
  def loc_cnarration_folder
    @loc_cnarration_folder ||= './data/unan/pages_semidyn/cnarration'
  end

  # Dossier narration distant
  def dis_cnarration_folder
    @dis_cnarration_folder ||= './www/data/unan/pages_semidyn/cnarration'
  end

  # Dossier local des pages non formatées
  def loc_cnarration_raw_folder
    @loc_cnarration_raw_folder ||= './data/unan/pages_cours/cnarration'
  end
  def dis_cnarration_raw_folder
    @dis_cnarration_raw_folder ||= './www/data/unan/pages_cours/cnarration'
  end

  # ---------------------------------------------------------------------
  #   SOUS MÉTHODES
  # ---------------------------------------------------------------------

  # Pour actualiser le niveau de développement d'une page
  #
  # Retourne la donnée locale actualisée
  def update_niveau_developpement(pid, loc_data, dis_data)
    loc_niv = loc_data[:options][1].to_i(11)
    dis_niv = dis_data[:options][1].to_i(11)
    good_niv = loc_niv > dis_niv ? loc_niv : dis_niv

    loc_data[:options][1] = good_niv.to_s(11)
    dis_data[:options][1] = good_niv.to_s(11)

    if loc_niv > dis_niv
      dis_table.update(pid, {options: dis_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{loc_niv}"
    else
      loc_table.update(pid, {options: loc_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{dis_niv}"
    end
    return loc_data
  end

  def db_suffix   ; @db_suffix  ||= :cnarration end
  def table_name  ; @table_name ||= 'narration' end

end #/CNarration

# Pour la table 'tdms'
# Usage Sync::TDMNarration.instance.loc_table ou dis_table, etc.
class TDMNarration
  include Singleton
  include CommonSyncMethods

  # Retourne le nombre de synchronisations
  def synchronize sync
    @sync = sync

    nombre_synchronisations = 0

    loc_rows.each do |rid, loc_data|
      dis_data = dis_rows[rid]
      # suivi "#{loc_data.inspect} / #{dis_data.inspect}"
      if dis_data.nil?
        # Une table des matières inexistante, c'est-à-dire
        # un nouveau livre initié
        dis_table.insert(loc_data)
        nombre_synchronisations += 1
      elsif loc_data != dis_data
        if dis_data[:updated_at] > loc_data[:updated_at]
          dis_data.delete(:id)
          loc_table.update(rid, dis_data)
        else
          loc_data.delete(:id)
          dis_table.update(rid, loc_data)
        end
        nombre_synchronisations += 1
      else
        # Les deux données sont identiques, rien à faire
      end
    end

    return nombre_synchronisations
  end

  def db_suffix   ; @db_suffix  ||= :cnarration end
  def table_name  ; @table_name ||= 'tdms'      end
end #/TDMNarration
end #/Sync
