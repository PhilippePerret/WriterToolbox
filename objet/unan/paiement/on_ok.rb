# encoding: UTF-8

# Requérir le minimum pour faire tourner Unan
# Pour le moment, juste pour récupérer le titre qui
# a une mise en forme spéciale (Unan::titre_h1)
(site.folder_objet+'unan/lib/required/unan').require

debug "-> unan/user/paiement/on_ok.rb"
class SiteHtml
class Paiement

  # Pour procéder à l'enregistrement du paiement quand c'est pour
  # le programme UN AN UN SCRIPT, il suffit de redéfinir les
  # données et d'appeler la méthode save_paiement (plus bas)
  def data_paiement
    @data_paiement ||= {
      user_id:    user.id,
      objet_id:   "1AN1SCRIPT",
      montant:    montant,
      facture:    token,
      created_at: Time.now.to_i
    }
  end
end #/Paiement
end #/SiteHtml

site.paiement.save_paiement
site.paiement.send_mail_to_user


debug "<- unan/user/paiement/on_ok.rb"
