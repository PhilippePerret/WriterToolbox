# encoding: UTF-8
class SyncRestsite
class App

  # Retourne true si le file (fichier/dossier) de chemin relatif
  # +rel_path+ est exclu de l'application (de la comparaison/synchronisation)
  #
  # Noter que +rel_path+ NE commence PAS par "./"
  #
  def exclude? rel_path
    folders_out.include?(rel_path) || files_out.include?(rel_path)
  end

end #/App
end #/SyncRestsite
