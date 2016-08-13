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

  # Pour démarrer les travaux de l'utilisateur
  #
  # Ça se fait en deux temps :
  #   1. récupération des travaux à démarrer
  #   2. démarrage des travaux
  #
  # +what+
  #   SI
  #     :all    Tous les travaux à démarrer
  def demarre_ses_travaux what
    puts "-> démarrage des travaux"
    self.current_pday.aworks_unstarted.each do |hwork|
      puts "- #{hwork.inspect}"
    end
    self.current_pday.aworks_ofday.each do |hwork|
      puts "- #{hwork.inspect}"
    end
    puts "<- démarrage des travaux"
  end

end
