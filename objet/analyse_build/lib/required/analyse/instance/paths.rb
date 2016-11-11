# encoding: UTF-8
class AnalyseBuild

  # Fichier Marshal contenant les données des scènes
  def scenes_file
    @scenes_file ||= folder + 'SCENES.msh'
  end
  def brins_file
    @brins_file ||= folder + 'BRINS.msh'
  end
  def personnages_file
    @personnages_file ||= folder + 'PERSONNAGES.msh'
  end

  # Le dossier des fichiers déposés par l'user
  def folder_depot
    @folder_depot ||= folder + 'depot'
  end
  # Le dossier principal du chantier
  def folder
    @folder ||= AnalyseBuild.user_folder_tmp + "#{film.id}"
  end

end
