# encoding: UTF-8
class SiteHtml
class Paiement

  # Data enregistrées dans la base de données pour
  # le paiement (table users.paiements)
  def data_paiement
    @data_paiement ||= {
      user_id:    user.id,
      objet_id:   objet_id,
      montant:    montant,
      facture:    token,
      created_at: Time.now.to_i
    }
  end

  def data_key
    @data_key ||= {
      PAYMENTREQUEST_0_CURRENCYCODE:    "EUR",
      PAYMENTREQUEST_0_PAYMENTACTION:   "SALE",
      CANCELURL:                        url_retour_cancel,
      RETURNURL:                        url_retour_ok
    }
  end

  # {String} Le montant en version Paypal
  # C'est une version avec les centimes mais sans devise
  def montant_paypal
    @montant_paypal ||= begin
      case montant
      when Fixnum then "#{montant}.00"
      else "#{montant}"
      end
    end
  end

  def payer_id
    @payer_id ||= param(:PayerID) || param(:payer_id)
  end


end #/Paiement
end #/SiteHtml
