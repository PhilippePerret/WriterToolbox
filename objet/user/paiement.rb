# encoding: UTF-8
app.require_optional 'paiement'

# La méthode de consignation du paiement
class SiteHtml::Paiement
  # Après validation du paiement, on peut l'enregistrer. En fait
  # cela consiste en deux opérations :
  #   1. Indiquer que l'user a payé en modifiant ses bits options
  #   2. Enregistrer le paiement dans la table des paiements
  def after_validation_paiement
    flash "Je passe par l'after validation paiement (supprimer ce message dans #{__FILE__})"
  end
end

# Instancier un paiement et le traiter en fonction de
# param(:pres)
site.paiement.make_transaction(
  montant:    site.tarif,
  objet:      "Abonnement d'un an au site pour utilisation des outils",
  objet_id:   "ABONNEMENT" # Pour la table
)
