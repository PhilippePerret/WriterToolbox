# encoding: UTF-8
site.require_module 'paiement'

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
      "#{user.pseudo}, puisque vous venez récemment de vous inscrire — moins de 6 mois —, votre abonnement au site de #{site.tarif_humain} est déduit de votre inscription de #{Unan::tarif_humain} au programme UN AN UN SCRIPT. Vous n'avez donc que <strong>#{tarif_unanunscript.as_tarif}</strong> à payer ! :-)"
    else
      "#{user.pseudo}, votre abonnement au site remontant à plus de 6 mois, vous devez payer l'inscription complète au programme, soit #{tarif_unanunscript.as_tarif}."
    end.in_p(class:'small')
  end

  # Return TRUE si l'user peut accéder au paiement du
  # programme Un AN UN SCRIPT
  def can_subscribe_to_1an1script?
    @can_subscribe_to_1an1script ||= begin
      identified? && !unanunscript?
    end
  end

  # Return TRUE si l'user vient juste de s'inscrire au programme
  # un an un script (dans les deux minutes qui précèdent ou le temps
  # défini par +depuis_secs+ en secondes)
  def just_subscribe_unanunscript?( depuis_secs = 120)
    @has_just_subscribe_unanunscript ||= begin
      unanunscript? && program.created_at > ( NOW.to_i - depuis_secs )
    end
  end

end #/User

def make_transaction_paiement_unanunscript
  # Instancier un paiement et le traiter en fonction de
  # param(:pres)
  site.paiement.make_transaction(
    montant:      user.tarif_unanunscript,
    objet:        "Inscription au programme “Un An Un Script”",
    objet_id:     "1AN1SCRIPT", # Pour la table
    context:      "unan",
    description:  "règlement de l'inscription au programme “1 An 1 Script”"
  )
end
# Pour passer par là, l'user doit être identifié (donc
# inscrit) et ne doit pas déjà suivre le programme
# UN AN UN SCRIPT
if user.can_subscribe_to_1an1script?
  make_transaction_paiement_unanunscript
end
