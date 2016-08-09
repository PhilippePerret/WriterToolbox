class User

  # Méthode pour passer l'utilisateur à un jour-programme
  # particulier
  #
  def set_pday_to index_pday, options = nil
    site.require_objet 'unan'
    created_at = NOW - index_pday * (24 * 3600)
    program.set(created_at: created_at, updated_at: created_at)
    program.current_pday= index_pday
  end

end
