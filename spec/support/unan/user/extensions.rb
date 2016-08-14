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
  #     :all    Tous les travaux à démarrer, c'est-à-dire ceux
  #             des jours précédents et ceux du jour courant.
  #
  def demarre_ses_travaux what
    puts "-> démarrage des travaux"

    # La liste qui va contenir tous les triplets de données
    # nécessaires pour créer le travail ([user, id abs work, pday abs work])
    arr_data = Array.new

    if what == :all
      arr_data +=
        self.current_pday.aworks_unstarted.collect do |hwork|
          # puts "- #{hwork.inspect}"
          [self, hwork[:awork_id], hwork[:pday]]
        end
    end
    if what == :all
      arr_data +=
        self.current_pday.aworks_ofday.collect do |hwork|
          # puts "- #{hwork.inspect}"
          [self, hwork[:awork_id], hwork[:pday]]
        end
    end

    # Le module qui permet de créer un work, ce qui correspond
    # au démarrage du travail.
    require './objet/unan/lib/module/work/create.rb'

    # On démarre tous ces travaux
    arr_data.each do |dstart|
      # dstart = [self, awork_id, work_pday]
      Unan::Program::Work.send(:start_work, *dstart)
    end

    puts "<- démarrage des travaux"
  end

end
