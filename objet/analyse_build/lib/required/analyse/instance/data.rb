# encoding: UTF-8
class AnalyseBuild

  # Enregistre tous les données dans un seul fichier Marshal, ainsi
  # que d'autres utiles comme les temps de création et de modification
  def update_all_data_in_file
    now =  Time.now.to_i
    @all_data_in_file = {
      film_id:      chantier.film.id,
      film_titre:   chantier.film.titre,
      user_id:      user.id,
      scenes:       scenes,
      personnages:  personnages,
      brins:        brins,
      updated_at:   now,
      created_at:   ( all_data_in_file[:created_at] || now )
    }
    data_file.write(Marshal.dump(@all_data_in_file))
  end

  def all_data_in_file
    @all_data_in_file ||= begin
      if data_file.exist?
        Marshal.load(data_file.read)
      else
        Hash.new
      end
    end
  end

  # Enregistrement des scènes
  #
  # Dans le fichier marshal SCENES.msh + FDATA.msh
  def save_scenes
    scenes_file.write( Marshal.dump(scenes) )
    update_all_data_in_file
  end

  # Enregistrement des brins
  #
  # Dans le fichier marshal BRINS.msh + FDATA.msh
  def save_brins
    brins_file.write( Marshal.dump(brins))
    update_all_data_in_file
  end

  # Enregistrement des personnages
  #
  # Dans le fichier marshal PERSONNAGES.msh + FDATA.msh
  def save_personnages
    personnages_file.write(Marshal.dump(personnages))
    update_all_data_in_file
  end

  # Toutes les scènes récupérées.
  #
  # TODO Plus tard, on pourra en faire des instances permettant
  # de les manipuler facilement
  def scenes
    @scenes ||= begin
      if scenes_file.exist?
        Marshal.load(scenes_file.read)
      else
        Array.new
      end
    end
  end

  def brins
    @brins ||= begin
      if brins_file.exist?
        Marshal.load(brins_file.read)
      else
        Hash.new # attention, il peut y avoir une erreur, car au début c'est
                 # un Array
      end
    end
  end

  def personnages
    @personnages ||= begin
      if personnages_file.exist?
        Marshal.load(personnages_file.read)
      else
        Array.new
      end
    end
  end

end #/AnalyseBuild
