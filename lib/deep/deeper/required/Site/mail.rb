# encoding: UTF-8
class SiteHtml

  # @usage:   site.send_mail(data_mail)
  # Cf. optional/Site/mail.rb pour le détail
  def send_mail data_mail
    app.require_optional 'Site/mail'
    return exec_send_mail( data_mail )
  end

  # Envoi d'un mail à l'administration par
  # l'user courant
  # +data_mail+ a juste à définir :
  #   :message
  #   :subject
  def send_mail_to_admin data_mail
    data_mail.merge!(
      from: user.mail,
      to:   site.mail
    )
    send_mail data_mail
  end

end
