# encoding: UTF-8
=begin

Méthodes d'helper pour la section de paiement

=end
class SiteHtml
class Paiement

  # Le code final qui sortira
  attr_writer :output

  # {StringHTML} Return le code HTML à afficher dans la section
  # paiement. Trois possibilités :
  #   - le formulaire de paiement (bouton Paypal à cliquer)
  #   - la confirmation du paiement
  #   - le renoncement au paiement
  def output
    @output
  end

  # Le montant à payer, au format humain
  def montant_humain
    @montant_humain ||= montant.as_tarif
  end

end # /Paiement
end # /SiteHtml
