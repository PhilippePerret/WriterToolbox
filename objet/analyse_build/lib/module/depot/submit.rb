# encoding: UTF-8
=begin
  Module s'occupant du dépot du fichier après soumission
=end
class Analyse
class Depot
class << self

  # Méthode principale appelée lorsque l'analyste soumet un fichier d'analyse.
  #
  # Ce fichier est enregistré dans le dossier temporaire et va être analysé
  # et parsé suivant son type.
  #
  # Un fichier de données est également enregistré pour se souvenir du
  # type donné pour le fichier et autres informations utiles.
  #
  def submit_file
    # On va déterminer l'identifiant du film. On doit toujour obtenir un
    # nombre, même lorsque c'est soit la valeur minuscule qui est donnée
    # soit l'identifiant avec année.
    idfilm = data_depot[:film].to_i_inn
    idfilm != nil || begin
      error 'Il faut impérativement définir l’identifiant du film.'
      return false
    end

    site.require_objet 'filmodico'
    filmo   = Filmodico.new(idfilm)
    film_id = filmo.id rescue begin
      error "Impossible de trouver le film désigné par `#{idfilm}`…"
      return false
    end

    # On met ce chantier en chantier courant
    AnalyseBuild.current = AnalyseBuild.new(film_id)
    AnalyseBuild.current.suivi "* Dépôt des fichiers…"

    # Le dossier du film doit être détruit avant le travail
    # si la case à cocher le demande.
    # Noter que c'est seulement le dossier de l'user, pas un dossier
    # général du film. De toute façon, aucune modification ne peut être
    # faite sur une donnée générale.
    if param(:detruire_dossier_film) == 'on'
      AnalyseBuild.current.folder.exist? && AnalyseBuild.current.folder.remove
    end

    # === PARSE DES TROIS TYPES DE FICHIER ===
    #
    # On boucle sur les trois types de fichier qui ont pu être
    # soumis
    [:scenes, :personnages, :brins].each do |type|
      # Le superfile pour faire l'upload
      # Note : le nom ne sera pas remplacé
      sf = AnalyseBuild.user_folder_tmp + "#{film_id}/depot/#{type}.txt"

      options = {
        change_name:  false,
        nil_if_empty: true
      }
      res = sf.upload(data_depot[type][:fichier], options)
      res != nil || next

      AnalyseBuild.current.suivi "** Dépôt du fichier de type #{type}"

      # On crée aussi un fichier de data qui permet de consigner les
      # informations sur le fichier, notamment pour savoir ce qu'il est,
      # un fichier de collecte, de brins, de personnages, etc.
      data_file = {
        name:     sf.name,
        film_id:  film_id,
        ftype:    data_depot[type][:ftype],
        type:     type
      }
      data_file_path = SuperFile.new(sf.path + '.data')
      data_file_path.write(data_file.to_json)
    end
    # /boucle sur les types de fichier possible

    # === DONNÉES DU FILM ===
    #
    # On crée le fichier des données du film (FILM.msh) ou on lit les données
    # déja enregistrées si le fichier existe déjà
    data_film =
      if chantier.data_film_file.exist?
        Marshal.load(data_film_file.read)
      else
        data_film = {
          id:         film_id,
          titre:      filmo.titre,
          director:   filmo.director,
          created_at: Time.now.to_i
        }
      end

    # On enregistre les nouvelles données ou les données actualisées.
    chantier.data_film_file.write Marshal.dump(data_film.merge(
      duree:      AnalyseBuild.current_film_duree,
      updated_at: Time.now.to_i
      ))

  rescue Exception => e
    debug e
    error "Une erreur est survenue au cours de la soumission : #{e.message}"
  else
    return true
  end

  # Les données du formulaire de dépôt d'un fichier
  #
  # Si non défini, retourne un Hash vide.
  def data_depot
    @data_depot ||= param(:depot) || data_depot_defaut
  end

  def data_depot_defaut
    {
      film_id:      nil,
      scenes:       Hash.new,
      personnages:  Hash.new,
      brins:        Hash.new
    }
  end

end #/<< self
end#Depot
end#Analyse
