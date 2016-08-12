# encoding: UTF-8
=begin

  Procédure tout à fait isolée pour envoyer des mails à
  l'administration depuis le site

  USAGE
  -----

      CRONMail.new(:subject, :message).send

=end
require 'cgi'
require 'net/smtp'

class CRONMail

  attr_reader :subject, :message

  def initialize data
    @subject = data[:subject]
    @message = data[:message]
    require File.join(APP_FOLDER,'data','secret','data_mail')
  end

  # = main =
  #
  # Envoi du message
  #
  def send
    Net::SMTP.start(
      MY_SMTP[:server],
      MY_SMTP[:port],
      (ENV['HOSTNAME'] || 'localhost'),
      MY_SMTP[:user],
      MY_SMTP[:password]
      ) do |smtp|
        smtp.send_message code_mail, admin_mail, admin_mail
    end
    nil
  rescue Exception => e
    return e
  end

  # = mail =
  #
  # Code final qui doit être envoyé
  #
  def code_mail
    "From: <#{admin_mail}>\nTo: <#{admin_mail}>\nMIME-Version: 1.0\nContent-type: text/html; charset=UTF-8\nSubject: #{subject}\n\n#{message_formated}"
  end

  def message_formated
    @message_formated ||= <<-HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>#{subject}</title>
  </head>
  <body>
    #{message}
  </body>
</html>
    HTML
  end

  def admin_mail
    @admin_mail ||= DATA_MAIL[:mail]
  end

end
