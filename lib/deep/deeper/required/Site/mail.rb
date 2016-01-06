# encoding: UTF-8
class SiteHtml

  # Cf. optional/Site/mail.rb pour le détail
  def send_mail data_mail
    app.require_optional 'Site/mail'
    exec_send_mail data_mail
  end

end
