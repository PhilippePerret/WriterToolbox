# encoding: UTF-8
class AnalyseBuild

  # Méthode principale qui parse tous les fichiers du chantier du film
  # Le fichier des scènes, s'il existe, est traité en dernier parce qu'on a
  # besoin de tous les autres avant de le traiter.
  # 
  def parse
    # On doit d'abord parser tous les fichiers sauf la collecte, pour
    # avoir les brins, personnages, etc.
    fichier_scenes = nil
    files.each do |file|
      file.type != :scene || begin
        fichier_scenes = file
        next
      end
      file.parse
    end
    fichier_scenes && fichier_scenes.parse
  end

end#/AnalyseBuild
