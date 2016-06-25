# encoding: UTF-8
class SiteHtml

  # @usage:   site.send_mail(data_mail)
  # Cf. optional/Site/mail.rb pour le détail
  def send_mail data_mail
    site.require_module 'mail'
    return exec_send_mail( data_mail )
  end

  # Envoi d'un mail à l'administration par
  # l'user courant
  # +data_mail+ a juste à définir :
  #   :message
  #   :subject
  #
  # La méthode peut être utilisée par le cron job par exemple
  # et, dans ce cas, l'user ne doit pas être défini, il faut
  # donc mettre le mail du site.
  #
  def send_mail_to_admin data_mail
    expediteur =
      if user && user.instance_of?(User) && user.mail
        user.mail
      else
        site.mail
      end
    send_mail data_mail.merge(from: expediteur, to: site.mail)
  end

end
