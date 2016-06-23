# encoding: UTF-8
class Sync
  def synchronize_filmodico
    @report << "* Synchronisation du FILMODICO"
    if Sync::Filmodico.instance.synchronize(self)
      @report << "= Synchronisation du FILMODICO OPÉRÉE AVEC SUCCÈS"
    else
      mess_err = "# ERREUR pendant la synchronisation du FILMODICO".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Filmodico
  include Singleton
  include CommonSyncMethods

  # = main =
  #
  # Méthode principale de synchronisation du Filmodico.
  # Le Filmodico doit être synchronisé de deux façons :
  #   - la base de donnée (table 'filmodico' dans :biblio)
  #   - les affiches de film (de local vers boa)
  #
  # Note : Maintenant, on ne synchronise plus sur Icare, car
  # tout est pris de Boa.
  #
  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0
    synchronize_fiches_database
    synchronize_affiches
    if @nombre_synchronisations > 0
      report "  NOMBRE DE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
    end
  rescue Exception => e
    error e.message
    false
  else
    true
  end

  # Synchronisation des fiches dans la base de données.
  #
  # Rappel : C'est en ONLINE qu'on peut faire les modifications
  # donc si les fiches sont différentes, c'est toujours la table
  # local qu'on modifie.
  def synchronize_fiches_database
    report "  * Synchronisation des fiches dans les bases de données"
    dis_rows.each do |fid, dis_data|
      loc_data = loc_rows[fid]

      if loc_data.nil?
        # La fiche du film n'existe pas localement
        # => Il faut la créer
        # ==== ACTUALISATION ===========
          loc_table.insert(dis_data)
          @nombre_synchronisations += 1
        # ==============================
        report "    = Création de la fiche du film #{dis_data[:titre]}"
      elsif dis_data != loc_data
        # Les fiches sont différentes
        # => Il faut actualiser la fiche locale
        # ======== ACTUALISATION =========
          dis_data.delete(:id)
          loc_table.update(fid, dis_data)
          @nombre_synchronisations += 1
        # =================================
        report "    = Modification de la fiche du film #{dis_data[:titre]}"
      else
        # Les deux fiches sont identiques
        suivi "Fiche film “#{dis_data[:titre].force_encoding('utf-8')}” OK"
      end
    end
    report "  = Synchronisation des fiches OK"
  end

  # Synchronisation des affiches
  def synchronize_affiches
    report "  * Synchronisation des affiches"
    loc_affiches_folder = './view/img/affiches'
    dis_affiches_folder = './www/view/img/affiches'
    sync_files loc_affiches_folder, dis_affiches_folder
    report "  = Synchronisation des affiches OK"
  end

  def db_suffix ; @db_suffix ||= :biblio        end
  def table_name ; @table_name ||= 'filmodico'  end
end #/Filmodico
end #/Sync
