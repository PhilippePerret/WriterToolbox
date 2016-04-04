# encoding: UTF-8
=begin
Contrôleur de la page sync.erb (les boutons)
=end
class Sync

  # Répond au bouton pour lancer une actualisation du
  # check. Il suffit de détruire les fichiers temporaires
  def force_check_synchro
    reset_all
  end

  
end
