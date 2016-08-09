class User

  # Méthode pour passer l'utilisateur à un jour-programme
  # particulier
  #
  def set_pday_to index_pday, options = nil
    site.require_objet 'unan'
    program.current_pday= index_pday
  end

end
