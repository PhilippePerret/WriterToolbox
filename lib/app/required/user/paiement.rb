# encoding: UTF-8
=begin

  Module de gestion du paiement de l'user

=end

class User

  # Méthode appelée tout de suite après l'enregistrement d'un
  # paiement dans la table des paiements.
  # Elle se charge d'enregistrer l'autorisation pour l'user
  # courant
  def on_paiement data_paiement
    debug "-> on_paiement(data_paiement = #{data_paiement.inspect})"
    Dir["./lib/app/module/user_autorisation/**/*.rb"].each{ |m| require m }
    do_on_paiement data_paiement
  end

end #/User
