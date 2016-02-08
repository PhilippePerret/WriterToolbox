class User

  # Méthode pour passer l'utilisateur à un jour-programme
  # particulier
  # NOTE : Ne fonctionne que sur Benoit ?
  def set_pday_to index_pday, options = nil
    site.require_objet 'unan'
    Unan::require_module 'quiz'
    (site.folder_lib_optional+'console/pday_change').require
    change_pday index_pday, options
  end

end
