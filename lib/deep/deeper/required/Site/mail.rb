# encoding: UTF-8
class SiteHtml

  # Cf. optional/Site/mail.rb pour le détail
  def send_mail data_mail
    # puts "J'envoie le mail à #{data_mail[:to]}"
    app.require_optional 'Site/mail'
    exec_send_mail data_mail
  end

end
