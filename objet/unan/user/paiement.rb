# encoding: UTF-8
app.require_optional 'paiement'

# La méthode de consignation du paiement
class SiteHtml::Paiement
  def consigner_paiement
    raise "Il faut implémenter la méthode de consignation du paiement."
  end
end

# Instancier un paiement et le traiter en fonction de
# param(:pres)
site.paiement.make_transaction(montant: site.tarif, context: 'unan')
