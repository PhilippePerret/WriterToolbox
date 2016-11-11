# encoding: UTF-8
=begin
  Module s'occupant du dépot du fichier après soumission
=end
class Analyse
class Depot
class << self

  # Méthode principale appelée lorsque l'analyse soumet un fichier d'analyse.
  #
  # Ce fichier est enregistré dans le dossier temporaire et va être analysé
  # et parsé suivant son type.
  #
  # Un fichier de données est également enregistré pour se souvenir du
  # type donné pour le fichier.
  #
  def submit_file

    # On va déterminer l'identifiant du film. On doit toujour obtenir un
    # nombre, même lorsque c'est soit la valeur minuscule qui est donnée
    # soit l'identifiant avec année.
    idfilm = data_depot[:film].nil_if_empty
    idfilm != nil || begin
      error 'Il faut impérativement définir l’identifiant du film.'
      return
    end
    idfilm.numeric? && idfilm = idfilm.to_i

    site.require_objet 'filmodico'
    film_id = Filmodico.new(idfilm).id rescue begin
      error "Impossible de trouver le film désigné par `#{idfilm}`…"
      return
    end


    # Le superfile pour faire l'upload
    # Note : le nom sera remplacé par le nom original
    sf = AnalyseBuild.user_folder_tmp + "#{film_id}/depot/fichier.ext"

    options = {
      nil_if_empty: true
    }
    res = sf.upload(data_depot[:fichier], options)
    res != nil || begin
      error 'Il faut donner le fichier !'
      return false
    end

    # On crée aussi un fichier de data qui permet de consigner les
    # informations sur le fichier, notamment pour savoir ce qu'il est,
    # un fichier de collecte, de brins, de personnages, etc.
    data_file = {
      name:     sf.name,
      film_id:  film_id,
      ftype:    data_depot[:ftype]
    }
    data_file_path = SuperFile.new(sf.path + '.data')
    data_file_path.write(data_file.to_json)

    flash "Le fichier `#{sf.name}` a été soumis avec succès."
  end

  # Les données du formulaire de dépôt d'un fichier
  #
  # Si non défini, retourne un Hash vide.
  def data_depot
    @data_depot ||= param(:depot) || Hash.new
  end

end #/<< self
end#Depot
end#Analyse
