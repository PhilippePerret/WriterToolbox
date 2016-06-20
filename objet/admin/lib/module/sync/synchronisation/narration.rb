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
      @report << "= Synchronisation de la collection Narration OPÉRÉE AVEC SUCCÈS"
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

    report "NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}"
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

    # Boucle sur chaque page locale
    # Note : Puisque les pages ne peuvent être que créées localement,
    # il est inutile de vérifier les pages distantes.
    loc_rows.each do |pid, loc_data|
      dis_data = dis_rows[pid]

      if loc_data != dis_data
        # Données différentes
        # Si c'est le niveau de développement qui a changé, il faut
        # updater le niveau le plus bas.
        # Si c'est une autre donnée qui a changé, il faut prendre
        # l'updated_at pour voir la plus récente (et signaler quand même
        # un problème si c'est en online que la modification est la plus
        # récente, ce qui ne devrait pas vraiment arriver)
        if loc_data[:options][1] != dis_data[:options][1]
          # NIVEAU DE DÉVELOPPEMENT DIFFÉRENT
          update_niveau_developpement(pid, loc_data, dis_data)
          @nombre_synchronisations += 1
        else
          # Autre donnée différente. Dans ce cas, on prend
          # la date de dernière modification pour savoir quelle
          # donnée doit être actualisée
          if loc_data[:udpated_at] > dis_data[:updated_at]
            # OK => actualisation de la donnée distante
            dis_table.update(pid, loc_data)
            @nombre_synchronisations += 1
          else
            # Actualisation de la donnée locale, mais attention,
            # c'est bizarre puisqu'on ne devrait pas modifier les
            # données en distant.
            loc_table.update(pid, dis_data)
            @nombre_synchronisations += 1
          end
        end
      else
        suivi "Pages ##{pid} loc/dis identifiques"
      end
    end
  end

  def synchronize_fichiers
    report "* Synchronisation des fichiers physiques"
    sync_files loc_cnarration_folder, dis_cnarration_folder
    report "= Synchronisation des fichiers physiques OK"
  end

  # ---------------------------------------------------------------------
  #   SOUS-MÉTHODES DE SYNCHRONISATION
  # ---------------------------------------------------------------------

  # Actualisation d'un fichier ERB distant
  #
  def upload_narration_file relpath
    loc_fullpath = "#{loc_cnarration_folder}/#{relpath}"
    dis_fullpath = "#{dis_cnarration_folder}/#{relpath}"
    retour = upload_file loc_fullpath, dis_fullpath
  end

  # Dossier narration local
  def loc_cnarration_folder
    @loc_cnarration_folder ||= './data/unan/pages_semidyn/cnarration'
  end

  # Dossier narration distant
  def dis_cnarration_folder
    @dis_cnarration_folder ||= './www/data/unan/pages_semidyn/cnarration'
  end

  # ---------------------------------------------------------------------
  #   SOUS MÉTHODES
  # ---------------------------------------------------------------------

  # Pour actualiser le niveau de développement d'une page
  def update_niveau_developpement(pid, loc_data, dis_data)
    loc_niv = loc_data[:options][1].to_i
    dis_niv = dis_data[:options][1].to_i
    if loc_niv > dis_niv
      dis_table.update(pid, {options: loc_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{loc_niv}"
    else
      loc_table.update(pid, {options: dis_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{dis_niv}"
    end
  end

  def db_suffix   ; @db_suffix  ||= :cnarration end
  def table_name  ; @table_name ||= 'narration' end


  # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
  # Note : Défini dans './objet/site/data_synchro.rb'
  def serveur_ssh
    @serveur_ssh ||= begin
      require './objet/site/data_synchro.rb'
      Synchro::new().serveur_ssh
    end
  end
  alias :serveur_ssh_boa :serveur_ssh


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
      if loc_data != dis_data
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
