# encoding: UTF-8
class SiteHtml

  # ---------------------------------------------------------------------
  #   URLs
  # ---------------------------------------------------------------------
  def local_url
    @local_url ||= "http://#{local_host}"
  end
  def distant_url
    @distant_url ||= "http://#{distant_host}"
  end

  # ---------------------------------------------------------------------
  #   Méthodes utiles pour les paths
  # ---------------------------------------------------------------------

  # Construit le dossier si nécessaire.
  # Noter que ça ne sert pas seulement à site
  # @usage    site.get_and_build_folder( path/to/folder )
  def get_and_build_folder sfile
    sfile = SuperFile::new(sfile) unless sfile.instance_of?(SuperFile)
    sfile.build unless sfile.exist?
    return sfile
  end

  # ---------------------------------------------------------------------
  #   Données
  # ---------------------------------------------------------------------
  def folder_data_secret
    @folder_data_secret ||= get_and_build_folder(folder_data+'secret')
  end
  def folder_data
    @folder_data ||= get_and_build_folder('./data')
  end

  # ---------------------------------------------------------------------
  #   Images
  # ---------------------------------------------------------------------
  def folder_deep_images
    @folder_deep_images ||= get_and_build_folder( folder_images + 'deep' )
  end
  def folder_images
    @folder_images ||= get_and_build_folder('./view/img')
  end
  # ---------------------------------------------------------------------
  #   Database
  # ---------------------------------------------------------------------

  def folder_db_users
    folder_db_users ||= get_and_build_folder(folder_db + 'user')
  end

  # Les données de l'application, c'est-à-dire le contenu de
  # toutes les bases de données
  def folder_db
    @folder_db ||= get_and_build_folder(folder_database + 'data')
  end

  # Dossier qui contient la définition des tables
  def folder_tables_definition
    @folder_tables_definition ||= get_and_build_folder(folder_database + 'tables_definition')
  end
  def folder_database
    @folder_database ||= get_and_build_folder('./database')
  end


  # ---------------------------------------------------------------------
  #   Vues (hors vue d'objet)
  # ---------------------------------------------------------------------

  # Le dossier gabarit, mais dans le dossier view
  def folder_custom_gabarit
    @folder_custom_gabarit ||= folder_view + 'gabarit'
  end
  def folder_gabarit
    @folder_gabarit ||= folder_deeper_view + 'gabarit'
  end

  def folder_deeper_view
    @folder_deeper_view ||= folder_deep_view + 'deeper'
  end
  def folder_deep_view
    @folder_deep_view ||= folder_view + 'deep'
  end
  def folder_view
    @folder_view ||= SuperFile::new('./view')
  end

  # ---------------------------------------------------------------------
  #   Modules
  # ---------------------------------------------------------------------
  def folder_deeper_module
    @folder_deeper_module ||= folder_deeper + 'module'
  end

  # ---------------------------------------------------------------------
  #   Librairie
  # ---------------------------------------------------------------------
  def folder_lib_per_route
    @folder_lib_per_route ||= folder_lib_optional + '_per_route'
  end
  def folder_lib_optional
    @folder_lib_optional ||= folder_deeper + 'optional'
  end
  def folder_deeper
    @folder_deeper ||= folder_lib + "deep/deeper"
  end
  def folder_lib
    @folder_lib ||= SuperFile::new('./lib')
  end

  # ---------------------------------------------------------------------
  #   Objet
  # ---------------------------------------------------------------------

  def folder_objet
    @folder_objet ||= SuperFile::new('./objet')
  end

end
