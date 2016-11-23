# encoding: UTF-8
class AnalyseBuild

  def scenes_depot_file
    @scenes_depot_file ||= folder_depot + 'scenes.txt'
  end
  def brins_depot_file
    @brins_depot_file ||= folder_depot + 'brins.txt'
  end
  def personnages_depot_file
    @personnages_depot_file ||= folder_depot + 'personnages.txt'
  end

  # Fichier Marshal contenant les données des scènes
  def scenes_file
    @scenes_file ||= folder + 'SCENES.msh'
  end
  # Fichier HTML contenant le listing des scènes
  # Correspond à l'évènemencier
  def scenes_html_file
    @scenes_html_file ||= folder + 'scenes.html'
  end

  # Fichier Marshal contenant les données des brins
  def brins_file
    @brins_file ||= folder + 'BRINS.msh'
  end
  # Fichier HTML contenant le listing des brins avec leurs scènes
  def brins_html_file
    @brins_html_file ||= folder + 'brins.html'
  end

  # Fichier Marshal contenant les données des Personnages
  def personnages_file
    @personnages_file ||= folder + 'PERSONNAGES.msh'
  end
  # Fichier HTML contenant la liste des personnages
  # Pour le moment, ne contient que ça, mais à l'avenir, on pourrait
  # avoir les scènes et les brins
  def personnages_html_file
    @personnages_html_file ||= folder + 'personnages.html'
  end
  def data_file
    @data_file ||= folder + 'FDATA.msh'
  end

  def data_film_file
    @data_film_file ||= folder + 'FILM.msh'
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
