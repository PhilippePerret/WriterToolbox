# encoding: UTF-8
unless user.identified?
  flash "Vous devez au préalable vous inscrire sur le site."
  param(route_after_signup: "user/paiement")
  redirect_to 'user/signup'
else
  app.require_optional 'paiement'

  # La méthode de consignation du paiement
  class SiteHtml::Paiement
    # Après validation du paiement, on peut l'enregistrer. En fait
    # cela consiste en deux opérations :
    #   1. Indiquer que l'user a payé en modifiant ses bits options
    #   2. Enregistrer le paiement dans la table des paiements
    # def after_validation_paiement
    # end
  end

  # Instancier un paiement et le traiter en fonction de
  # param(:pres)
  site.paiement.make_transaction(
    montant:      site.tarif,
    objet:        "Abonnement d'un an au site “#{site.name}”",
    objet_id:     "ABONNEMENT", # Pour la table
    description:  "paiement de l'abonnement d'un an" # pour le formulaire
  )
end
