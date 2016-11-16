# encoding: UTF-8
class AnalyseBuild

  # = main =
  #
  # Méthode principale qui construit tous les fichiers qu'on peut
  # tirer des fichiers de collecte.
  # Pour le moment, on ne peut rien préciser mais plus tard on pourra
  # demander de construire tel ou tel fichier en repartant des données
  # enregistrées dans le fichier marshal FDATA.
  #
  def build_all_fichiers
    suivi '* Construction de tous les fichiers possibles…'

    # Construction les différents types dévènemencier si le fichier
    # de collecte des scènes a été fourni
    collect_scenes_provided? && build_events

    # Construction des brins si le fichier de collecte des brins a été
    # fournir
    collect_brins_provided? && build_brins

    flash 'Construction opérée avec succès.'
  end
  # /build_all_fichiers

end#/AnalyseBuild
