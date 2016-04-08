# encoding: UTF-8
class SynchroAnalyse

  # {Array} Liste des messages de suivi des opérations
  attr_reader :suivi


  # = main =
  #
  # Méthode principale procédant à la synchronisation de la base
  # de données analyse.db des analyses de film.
  #
  # RETURN True en cas de succès, False dans le cas contraire
  #
  def synchronize
    @suivi = Array::new

    # On rappatrie la base analyse.db du site distant
    # BOA vers local en lui donnant le nom `analyse-distant.db`
    # pour ne pas qu'elle écrase la base existante
    download_distant_base
    # On ajuste les données au niveau du niveau de développement
    synchronise_data_of_analyse

    # On peut uploader la base du BOA
    @suivi << "* Upload de la base analyse.db"
    upload_base

    # On peut détruire le fichier local distant
    distant_local_path.remove
    @suivi << "* Base distante détruite en local"

  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    return false
  else
    return true
  end

  # ---------------------------------------------------------------------
  #   Méthodes de transformation des données
  # ---------------------------------------------------------------------
  def synchronise_data_of_analyse

    # Traiter les nouveaux films éventuellement ajoutés ONLINE
    # debug "ids_not_in_loc: #{ids_not_in_loc.inspect}"
    if ids_not_in_loc.count > 0
      ids_not_in_loc.each do |fid|
        dfilm = films_dis[fid]
        raise "Erreur dans la synchronisation des analyses. Film inconnu (alors qu'il devrait l'être)" if dfilm.nil?
        @suivi << "* Ajout du film ##{fid} : #{dfilm[:titre]}"
        table_loc.insert(dfilm)
      end
    else
      @suivi << "= Aucun nouveau film à ajouter"
    end

    # Traiter les sym pour voir s'ils ont changé
    films_dis.each do |fid, fdata|
      film_loc = films_loc[fid]
      next if film_loc.nil? # traité ci-dessus
      if fdata[:sym] != film_loc[:sym]
        # le sym a changé => modifier le film local
        @suivi << "Sym du film ##{fid} passé de #{film_loc[:sym]} à #{fdata[:sym]}"
        table_loc.update(fid, sym: fdata[:sym])
      end
    end

  end

  # Retourne la liste des ID de films qui se trouvent sur
  # la base distante mais pas sur la base locale. Ce sont
  # des nouveaux films.
  def ids_not_in_loc
    @ids_not_in_loc ||= begin
      keys_films_dis = films_dis.keys.sort
      keys_films_loc = films_loc.keys.sort
      films_out = Array::new
      while fid_dis = keys_films_dis.shift
        cur_loc = keys_films_loc.first
        if cur_loc.nil?
          films_out << fid_dis
        elsif fid_dis < cur_loc
          films_out << fid_dis
        else
          cur_loc = keys_films_loc.shift
          until fid_dis == cur_loc
            films_out << cur_loc
            cur_loc = keys_films_loc.shift
          end
        end
      end
      films_out
    end
  end

  def films_loc
    @films_loc ||= table_loc.select()
  end
  def films_dis
    @films_dis ||= table_dis.select()
  end
  def table_dis
    @table_dis ||= base_dis.table('films')
  end
  def table_loc
    @table_loc ||= base_loc.table('films')
  end
  def base_dis
    @base_dis ||= BdD::new(distant_local_path.to_s)
  end
  def base_loc
    @base_loc ||= BdD::new(path_local.to_s)
  end

end #/SynchroAnalyse
