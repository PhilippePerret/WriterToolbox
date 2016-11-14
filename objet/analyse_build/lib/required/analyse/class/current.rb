# encoding: UTF-8
class AnalyseBuild
class << self

  # Chantier courant. Il peut être soi défini par le dépot
  # courant de fichiers soit par l'url.
  attr_writer :current
  def current
    @current ||= site.current_route.instance
  end

  # Liste des films de l'user qui possèdent des fichiers temporaires
  # d'analyse.
  # RETURN Une liste d'instance Filmodico
  #
  # Chaque dossier dans user_folder_tmp est un dossier concernant un
  # film analysé par l'user.
  #
  def user_films_tmp
    @user_analyses_tmp ||= begin
      site.require_objet 'filmodico'
      Dir["#{user_folder_tmp}/*"].collect do |p|
        Filmodico.new(::File.basename(p).to_i)
      end
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
