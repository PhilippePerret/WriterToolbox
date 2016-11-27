# encoding: UTF-8
class AnalyseBuild
class << self

  # Pour pouvoir définir la durée du film courant au cours du parsing
  # du fichier de collecte
  # Rappel : on marque la fin du film par :
  #   x:xx:xx ->| FIN
  # ou :
  #   x:xx:xx ->| END
  attr_accessor :current_film_duree

  # Chantier courant. Il peut être soi défini par le dépot
  # courant de fichiers soit par l'url.
  attr_writer :current
  def current
    @current ||= site.current_route.instance || AnalyseBuild.new
  end

  # Liste des films de l'user qui possèdent des fichiers temporaires
  # d'analyse.
  # RETURN Une liste d'instance {Filmodico}
  #
  # Chaque dossier dans user_folder_tmp est un dossier concernant un
  # film analysé par l'user.
  #
  def user_films_tmp
    @user_analyses_tmp ||= films_tmp_of(user.id)
  end

  def other_user_films_tmp
    @other_user_films_tmp ||= begin
      uid = user.id
      liste_films = Array.new
      Dir["#{site.folder_tmp}/analyse/*"].each do |p|
        thisuserid = ::File.basename(p).to_i
        thisuserid != uid || next
        liste_films += films_tmp_of(thisuserid)
      end
      liste_films
    end
  end

  # Retourne la liste des films ({Array of Filmodico}) des films de
  # l'user d'identifiant +user_id+
  def films_tmp_of user_id
    site.require_objet 'filmodico'
    Dir["#{site.folder_tmp}/analyse/#{user_id}/*"].collect do |p|
      filmo = Filmodico.new(::File.basename(p).to_i)
      # On ajoute l'analyste
      filmo.analystes || filmo.analystes = Array.new
      filmo.analystes << User.new(user_id)
      filmo
    end
  end

  # Le dossier temporaire de l'user courant, dans le dossier
  # temporaire. C'est dans ce dossier que seront déposés tous les
  # fichiers avant validation.
  #
  def user_folder_tmp
    @user_folder_tmp ||= site.folder_tmp + "analyse/#{user.id}"
  end

end #/<< self
end #/AnalyseBuild

class Filmodico
  # Liste des analystes du film. Utile pour savoir qui a analysé les films
  # en question.
  attr_accessor :analystes
end
