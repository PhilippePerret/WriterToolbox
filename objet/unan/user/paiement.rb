# encoding: UTF-8
app.require_optional 'paiement'

# Instancier un paiement et le traiter en fonction de
# param(:pres)
site.paiement.make_transaction(
  montant:    user.tarif_unanunscript,
  objet:      "Inscription au programme “Un An Un Script”",
  objet_id:   "1AN1SCRIPT", # Pour la table
  context:    "unan"
)
