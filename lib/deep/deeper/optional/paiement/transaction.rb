# encoding: UTF-8
class SiteHtml
class Paiement

  # Définir le contexte du paiement, lorsque ce n'est pas un paiement
  # pour le site lui-même, mais pour une sous-section.
  # Ce contexte est le dossier à partir de "./objet".
  #
  # @usage
  #   Définir la propriété :context dans le hash envoyé
  #   à la méthode make_transaction :
  #     site.paiement.make_transaction(montant: 120, context: "unan", ...)
  #
  attr_reader :context

  # Pour connaitre l'objet du paiement dans la table de données
  # des paiements, propriété de même nom.
  # Il faut transmettre cette donnée dans le Hash qui est donné
  # en argument de make_transaction.
  attr_reader :objet_id

  # Dossier de base du paiement. Par défaut, c'est le dossier './objet'
  # et il s'agit du paiement pour le site lui-même.
  def base_folder
    @base_folder ||= begin
      context.nil? ? site.folder_objet : (site.folder_objet + context)
    end
  end

  # = main =
  #
  # C'est la méthode principale qui doit être appelée
  # par la vue qui contient le traitement du paiement.
  # Pour l'utiliser, il suffit de mettre dans la vue :
  #   app.require_optional 'paiement'
  #   site.paiement.make_transaction
  #
  def make_transaction data_transaction

    @context  = data_transaction.delete(:context)
    @objet    = data_transaction.delete(:objet)
    @objet_id = data_transaction.delete(:objet_id)

    case param(:pres)
    when '1'
      # On passe par ici lorsque le paiement a été effectué avec succès
      # par l'utilisateur. On peut enregistrer le paiement et informer
      # l'user de ce qu'il peut faire maintenant.
      on_ok
    when '0'
      # On passe par ici lorsque le paiement a été annulé par
      # l'user ou par PayPal lui-même
      on_cancel
    else
      # Première arrivée dans la section de paiement, on va
      # instancier la procédure de paiement.
      # La méthode `init` ci-dessous va envoyer la première requête
      # à Paypal, avec le description du paiement, pour obtenir un
      # ticket (token) que le site placera dans le formulaire de
      # paiement.
      # Ensuite, la page affichera le formulaire avec le logo PayPal
      # pour pouvoir payer (note : ce formulaire est défini dans la
      # page paiement.erb mais c'est une méthode d'helper qui fourni
      # le code du formulaire : site.paiement.form).
      init( data_transaction )
      self.output = Vue::new('user/paiement/form', base_folder, self).output
    end
  end

  # Méthode appelée suite au paiement réussi par l'user
  # Noter qu'il faut encore valider le paiement auprès de
  # Paypal et l'enregistrer sur le site
  # TODO : Il faut faire un test pour voir si la vue existe
  def on_ok
    @token    = param(:token)
    @payer_id = param(:PayerID)
    if valider_paiement
      self.output = Vue::new('user/paiement/on_ok', base_folder, self).output
    else
      self.output = Vue::new('user/paiement/on_error', base_folder, self).output
    end
  end

  # Méthode appelée suite à l'annulation ou l'impossibilité
  # d'exécuter le paiement.
  # TODO : Il faut faire un test pour voir si la vue existe
  def on_cancel
    self.output = Vue::new('user/paiement/on_cancel', base_folder, self).output
  end

  # Enregistrer le paiement
  def save_paiement
    self.class::table_paiements.insert(data_paiement)
  end
  def data_paiement
    @data_paiement ||= {
      user_id:    user.id,
      objet_id:   objet_id,
      montant:    montant,
      facture:    token,
      created_at: Time.now.to_i
    }
  end

  # Envoyer un mail de confirmation à l'user
  def send_mail_to_user
    site.send_mail(
      from: site.mail,
      to:   user.mail,
      subject:  "Confirmation de votre paiement",
      message:  facture,
      formated: true
    )
  end
  # {StringHTML} Retourne le code pour la facture
  def facture
    @facture ||= begin
      <<-HTML
<p>Bonjour #{user.pseudo},</p>
<p>Veuillez trouver ci-dessous votre facture pour votre paiement.</p>
<table type="fixed">
  <colsgroup>
    <col width="200" />
    <col width="600" />
  </colsgroup>
  <tr>
    <td>Facture ID</td>
    <td>#{token}</td>
  </tr>
  <tr>
    <td>Émise par</td>
    <td>#{site.official_designation}</td>
  </tr>
  <tr>
    <td>Pour</td>
    <td>#{user.patronyme || user.pseudo} (utilisateur ##{user.id})<br />#{user.mail}</td>
  </tr>
  <tr>
    <td>Objet</td>
    <td>#{objet}</td>
  </tr>
  <tr>
    <td>Date</td>
    <td>#{NOW.to_i.as_human_date}</td>
  </tr>
  <tr>
    <td>Montant</td>
    <td>#{montant_humain}</td>
  </tr>
</table>
<p>Bien à vous et au plaisir ! :-)</p>
      HTML
    end
  end

end # /Paiement
end # /SiteHtml
