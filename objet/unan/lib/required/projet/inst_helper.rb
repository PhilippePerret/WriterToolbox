# encoding: UTF-8
class Unan
class Projet
  # Retourne le titre du projet sous forme de nom de dossier
  # Cette méthode a été initiée pour les pages de cours du programme
  # qui ont besoin de connaitre le nom du projet.
  def titre_as_folder
    @titre_as_folder ||= begin
      titre != nil || flash('Il faudrait définir le titre de votre projet.')
      (titre || 'Mon Projet').as_normalized_filename
    end
  end
  alias :title_as_folder :titre_as_folder

end #/Projet
end #/Unan
