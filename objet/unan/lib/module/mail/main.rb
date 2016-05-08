# encoding: UTF-8
=begin
Extension de la class Unan pour l'envoi des mail

@usage

    Unan::send_mail data_mail

    Où `data_mail` définit :to, :from, :subject et :message

NOTE
  Ce module redéfinit les méthodes qui vont permettre de customiser les
  mails avec les fichiers contenus dans ce module.

=end
class Unan
  class << self

    def exec_send_mail data_mail
      site.require_module 'mail'
      SiteHtml::Mail::new(data_mail).send
    end

  end # << self
end # /Unan
