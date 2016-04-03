# encoding: UTF-8
class Sync

  # Méthode appelée quand le fichier est appelé
  # ONLINE pour vérifier la synchro. Il prend simplement
  # les données des fichiers spécifiés et retourne leur
  # date de dernière modification.
  #
  # RETURN : {Hash} Un tableau qui contient les dates de modifications
  # des fichiers à checker ainsi que quelques informations supplémentaires
  #
  def etat_des_lieux_online
    res = file_mtimes
  rescue Exception => e
    res = {
      date:           Time.now.to_i,
      err_mess:       e.message,
      err_backtrace:  e.backtrace
    }
  end

  # Méthode OFFLINE line qui :
  #   - demande par SSH les informations sur l'état des
  #     fichiers distants, sur la boite à outils et l'atelier
  #     Icare
  #   - enregistre les données retournées dans un fichier
  #     marshal pour utilisation ultérieure.
  def online_sync_state
    @online_sync_state ||= begin

      # Si le fichier existe et qu'il n'a pas encore une heure,
      # on utilise ses données au lieu de recommencer le check
      if check_data_path.exist? && check_data_path.mtime.to_i > (NOW - 3600)
        # On prend les données dans le fichier
        @suivi << "- Data checkées récupérées dans `#{check_data_path}`"
        Marshal::load(check_data_path.read)
      else
        # Il faut checker vraiment les fichiers, soit parce que le
        # fichier est trop vieux, soit par qu'il n'existe pas
        @suivi << "* Check SSH des fichiers distantes"

        # Sur le site de la boite à outils
        # commands = script_to_command(script_check_synchro)
        # debug "COMMANDS ENVOYÉES À BOA :\n#{commands}"
        res_boa = `ssh #{serveur_ssh} "ruby -e \\"#{script_check_synchro}\\""`
        res_boa = Marshal.load(res_boa)

        # Sur le site Icare
        # On vérifie les mêmes fichiers +
        #   - La liste des affiches
        #   - la liste des fichiers narration ? (pas fait encore)
        commands = script_to_command(script_check_icare)
        res_icare = `ssh #{serveur_ssh_icare} "ruby -e \\"#{script_check_icare}\\""`
        debug "Retour BRUT de res_icare : #{res_icare.inspect}"
        res_icare = Marshal.load(res_icare)
        # On merge les résultats
        res = res_boa.merge(icare: res_icare)

        # On enregistre ces données dans le fichier des données
        # checkées
        check_data_path.write Marshal::dump(res)

        res
      end
    end
  end

  # Méthode qui compare la liste des affiches de l'atelier Icare
  # avec la liste des affiches en local et donne la différence (les
  # affiches qui se trouvent en local et pas sur Icare et inversement,
  # dans le cas où des affiches sont modifiées)
  #
  # Cette méthode est appelée lorsque la synchro fabrique l'affichage
  # et la différence sera enregistrée dans les données pour procéder
  # à la synchronisation.
  #
  def diff_affiches_icare
    @diff_affiches_icare ||= begin
      affiches_on_icare = online_sync_state[:icare][:affiches].split(',')
      affiches_locales  = Dir['./view/img/affiches/*.jpg'].collect{|p| File.basename(p)}

      not_on_icare = Array::new
      not_on_local = Array::new

      # Vérification des affiches locales qui ne sont pas sur Icare
      affiches_locales.each do |affiche_name|
        if affiches_on_icare.index(affiche_name).nil?
          not_on_icare << affiche_name
        else
          affiches_on_icare.delete(affiche_name)
        end
      end

      # Les affiches restant dans affiches_on_icare n'existent pas en
      # local

      # On retourne les deux listes
      {
        upload_on_icare: not_on_icare,
        nombre_uploads:  not_on_icare.count,
        delete_on_icare: affiches_on_icare,
        nombre_deletes:  affiches_on_icare.count
      }
    end
  end

end #/Sync
