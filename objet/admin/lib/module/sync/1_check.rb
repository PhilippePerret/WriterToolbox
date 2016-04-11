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

      toutres = Hash::new

      # Si le fichier du test de synchro existe et qu'il n'a pas
      # encore une heure, on utilise ses données au lieu de recommencer
      # le check
      if check_data_path.exist? && check_data_path.mtime.to_i > (NOW - 3600)
        # On prend les données dans le fichier
        @suivi << "- Data checkées récupérées dans `#{check_data_path}`"
        Marshal::load(check_data_path.read)
      else
        # Il faut checker vraiment les fichiers, soit parce que le
        # fichier est trop vieux, soit par qu'il n'existe pas
        @suivi << "* Check SSH des fichiers distants"

        # Sur la boite à outils
        # ----------------------
        # debug "COMMANDS ENVOYÉES À BOA :\n#{commands}"
        res_boa = `ssh #{serveur_ssh} "ruby -e \\"#{script_check_boa}\\""`
        res_boa = Marshal.load(res_boa)
        toutres.merge!(boa: res_boa)

        # Sur le site Icare
        # ------------------
        # On vérifie les mêmes fichiers +
        #   - La liste des affiches
        #   - la liste des fichiers narration
        #   - la base cnarration.db (mtime)
        #   - les fichiers CSS propres à la collection
        res_icare = `ssh #{serveur_ssh_icare} "ruby -e \\"#{script_check_icare}\\""`
        # debug "\n\nscript_check_icare:#{script_check_icare}\n\n"
        # debug "res_icare non démarshalisé: #{res_icare.inspect}\n\n"
        # debug "Retour BRUT de res_icare : #{res_icare.inspect}"
        res_icare = Marshal.load(res_icare)
        # debug "res_icare démarshalisé : #{res_icare.pretty_inspect}\n\n"
        # On merge les résultats
        toutres.merge!(icare: res_icare)

        # On enregistre ces données dans le fichier des données
        # checkées
        check_data_path.write Marshal::dump(toutres)

        # Et on le met dans `online_sync_state`
        toutres
      end
    end
  end

  # Méthode principale qui compare les fichiers NARRATION sur
  # BOA avec les fichiers Locaux pour savoir ceux qui devront
  # être actualisés
  #
  # RETURN {Hash} des données contenant :
  #   :css => {
  #     all:                Liste de tous les fichiers
  #     distant_unknown:    Liste des fichiers à ajouter
  #     local_unknown:      Liste des fichiers à supprimer
  #     synchro_required:   Liste des fichiers à synchroniser
  #   }
  def diff_narration_boa
    dnar = online_sync_state[:boa][:cnarration]

    diff_naric = {
      css:    nil,
      files:  nil
    }

    # === Check des fichiers CSS ===
    files_loc = Array::new
    folder_css_common = File.join('.', 'view', 'css', 'common')
    folder_css_narration = File.join('.', 'objet','cnarration','lib','required','css')
    ['titres.css', 'textes.css', 'documents.css', 'markdown.css'].each do |ncss|
      pcss = File.join(folder_css_common, ncss)
      files_loc << [pcss, ncss, File.stat(pcss).mtime.to_i]
    end
    Dir["#{folder_css_narration}/*.css"].each do |pcss|
      ncss = File.basename(pcss)
      files_loc << [pcss, ncss, File.stat(pcss).mtime.to_i]
    end
    files_dis = dnar[:css]

    diff_naric[:css] = check_liste_icare_narration(files_loc, files_dis, 1)

    # === Check des fichiers ERB ===

    files_dis = dnar[:files]

    main_folder = File.join('.','data','unan','pages_semidyn','cnarration')
    files_loc = Dir["#{main_folder}/**/*.*"].collect do |pfile|
      nfile = File.basename(pfile)
      rfile = pfile.sub(/^#{main_folder}\//,'')
      mtime = File.stat(pfile).mtime.to_i
      [rfile, nfile, mtime]
    end

    diff_naric[:files] = check_liste_icare_narration(files_loc, files_dis, 0)

    # Nombre d'opérations totale à exécuter
    diff_naric[:nombre_operations] = diff_naric[:files][:nombre_operations] + diff_naric[:css][:nombre_operations]

    # debug "\n\ndiff_naric: #{diff_naric.pretty_inspect}\n\n"

    return diff_naric
  end



  # Méthode principale qui compare les fichiers NARRATION sur
  # ICARE avec les fichiers Locaux pour savoir ceux qui devront
  # être actualisés
  #
  # RETURN {Hash} des données contenant :
  #   :css => {
  #     all:                Liste de tous les fichiers
  #     distant_unknown:    Liste des fichiers à ajouter
  #     local_unknown:      Liste des fichiers à supprimer
  #     synchro_required:   Liste des fichiers à synchroniser
  #   }
  def diff_narration_icare
    dnar = online_sync_state[:icare][:cnarration]

    diff_naric = {
      css:    nil,
      files:  nil
    }

    # === Check des fichiers CSS ===
    files_loc = Array::new
    folder_css_common = File.join('.', 'view', 'css', 'common')
    folder_css_narration = File.join('.', 'objet','cnarration','lib','required','css')
    ['titres.css', 'textes.css', 'documents.css', 'markdown.css'].each do |ncss|
      pcss = File.join(folder_css_common, ncss)
      files_loc << [pcss, ncss, File.stat(pcss).mtime.to_i]
    end
    Dir["#{folder_css_narration}/*.css"].each do |pcss|
      ncss = File.basename(pcss)
      files_loc << [pcss, ncss, File.stat(pcss).mtime.to_i]
    end
    files_dis = dnar[:css]

    diff_naric[:css] = check_liste_icare_narration(files_loc, files_dis, 1)

    # === Check des fichiers ERB ===

    files_dis = dnar[:files]

    main_folder = File.join('.','data','unan','pages_semidyn','cnarration')
    files_loc = Dir["#{main_folder}/**/*.*"].collect do |pfile|
      nfile = File.basename(pfile)
      rfile = pfile.sub(/^#{main_folder}\//,'')
      mtime = File.stat(pfile).mtime.to_i
      [rfile, nfile, mtime]
    end

    diff_naric[:files] = check_liste_icare_narration(files_loc, files_dis, 0)

    # Nombre d'opérations totale à exécuter
    diff_naric[:nombre_operations] = diff_naric[:files][:nombre_operations] + diff_naric[:css][:nombre_operations]

    # debug "\n\ndiff_naric: #{diff_naric.pretty_inspect}\n\n"

    return diff_naric
  end

  def check_liste_icare_narration files_loc, files_dis, indice_ref
    hres = {
      all:                  Array::new,
      nombre_total:         nil,
      distant_unknown:      Array::new,
      nombre_unknown_dis:   nil,
      synchro_required:     Array::new,
      nombre_synchro_req:   nil,
      local_unknown:        Array::new,
      nombre_unknown_loc:   nil,
      # Nombre d'opérations totale qui seront à faire
      nombre_operations:    nil
    }
    # On check les synchros par rapport aux fichiers locaux
    files_loc.each do |path_loc, nfile, mtime_loc|
      item_ref = indice_ref == 0 ? path_loc : nfile
      hres[:all] << item_ref
      mtime_dis = files_dis.delete(item_ref)
      if mtime_dis.nil?
        #  => Fichier distant n'existe pas
        hres[:distant_unknown] << [path_loc, nfile]
      elsif mtime_dis == mtime_loc
        # => Fichier OK
      elsif mtime_dis > mtime_loc
        # ERREUR : C'EST NORMALEMENT IMPOSSIBLE
      elsif mtime_loc > mtime_dis
        hres[:synchro_required] << [path_loc, nfile]
      end
    end

    # Est-ce qu'il y a des fichiers distants à supprimer ?
    # Puisqu'on a retiré les fichiers à mesure du check ci-dessus
    # dans +files_dis+ il ne doit rester dans ce hash que les
    # fichiers à détruire.
    unless files_dis.empty?
      hres[:all]           += files_dis.keys
      hres[:local_unknown] = files_dis.keys
    end

    hres[:nombre_total]       = hres[:all].count
    hres[:all] = nil # pour ne pas encombrer
    hres[:nombre_unknown_dis] = hres[:distant_unknown].count
    hres[:nombre_unknown_loc] = hres[:local_unknown].count
    hres[:nombre_synchro_req] = hres[:synchro_required].count
    hres[:nombre_operations]  = hres[:nombre_unknown_dis]+hres[:nombre_unknown_loc]+hres[:nombre_synchro_req]

    # debug "\n\n\nhres:#{hres.pretty_inspect}\n\n\n"
    return hres
  end

  # Méthode principale qui compare les affiches sur la boite
  # online et sur Icare et retourne les données à enregistrer
  # pour la synchronisation future
  def diff_affiches
    @diff_affiches ||= begin
      resaff = Hash::new
      resaff.merge! nombre_actions: 0
      resaff.merge!( boa:   diff_affiches_boa )
      resaff[:nombre_actions] += diff_affiches_boa[:nombre_uploads] + diff_affiches_boa[:nombre_deletes]
      resaff.merge! icare: diff_affiches_icare
      resaff[:nombre_actions] += diff_affiches_icare[:nombre_uploads] + diff_affiches_icare[:nombre_deletes]
      resaff
    end
  end

  # Méthode qui compare la liste des affiches de la boite online
  # avec la liste offline.
  #
  # Cette méthode est appelée lorsque la synchro fabrique
  # l'affichage et la différence sera enregistrée dans les données
  # pour procéder à la synchronisation
  def diff_affiches_boa
    @diff_affiches_boa ||= begin
      affiches_on_boa = online_sync_state[:boa][:affiches].split(',')
      diff_affiches_in_listes liste_affiches_locales, affiches_on_boa
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
      diff_affiches_in_listes liste_affiches_locales, affiches_on_icare
    end
  end

  # Liste des affiches en local
  def liste_affiches_locales
    @liste_affiches_locales ||= Dir['./view/img/affiches/*.jpg'].collect{|p| File.basename(p)}
  end

  # Méthode commune checkant la liste des affiches et retournant
  # un hash définissant les affiches à uploader, les affiches à
  # détruire et leur nombre.
  def diff_affiches_in_listes arr_loc, arr_dis
    not_on_distant  = Array::new
    not_on_local    = Array::new

    # Vérification des affiches locales qui ne sont pas sur Icare
    arr_loc.each do |affiche_name|
      if arr_dis.index(affiche_name).nil?
        not_on_distant << affiche_name
      else
        arr_dis.delete(affiche_name)
      end
    end

    # Les affiches restant dans affiches_on_icare n'existent pas en
    # local

    # On retourne les deux listes avec leur nombre d'items
    {
      uploads:        not_on_distant,
      nombre_uploads: not_on_distant.count,
      deletes:        arr_dis,
      nombre_deletes: arr_dis.count
    }
  end

end #/Sync
