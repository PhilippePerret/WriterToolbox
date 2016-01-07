# encoding: UTF-8
class User

  # Méthode appelée lorsque l'user est déjà inscrit sur le
  # site pour voir le prix qu'il devra payer en réalité.
  # Si son abonnement date de plus de 9 mois, il lui faut
  # payer l'inscription complète, sinon, il a juste à payer
  # la différence.
  # {StringHTML} Retourne le code HTML du message indiquant
  # le tarif à payer par l'user
  def check_abonnement
    if abonnement_recent?(6)
      "Puisque vous venez récemment de vous inscrire (moins de 6 mois), votre abonnement au site est déduit de votre inscription au programme. Vous n'aurez donc que <strong>#{tarif_unanunscript.as_tarif}</strong> à payer."
    else
      "Votre abonnement au site remontant à plus de 6 mois, vous devez payer l'inscription complète au programme, soit #{tarif_unanunscript.as_tarif}."
    end.in_p
  end

end #/Unan
