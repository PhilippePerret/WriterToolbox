# encoding: UTF-8
=begin

  Class MiniMail
  --------------
  Classe indépendante pour envoyer des mails sans passer par
  les modules du site.

  NE PAS UTILISER POUR ENVOYER DES MESSAGES AUX UTILISATEURS ou
  alors s'arranger pour mettre un entête conforme.

  @syntaxe

      MiniMail.new().send(<message>[, <sujet>[, <options>]])

      <options>
        :to   Le mail du destinataire - par défaut, l'admin
        :from Le mail de l'expéditeur - par défaut, l'admin
        :log_error  Si true, on ajoute le log des erreurs
        :log        Si true, on ajoute le log complet
        :format     'plain' (default) ou 'html'


  Note : Cette classe est toujours chargée par le cron, dont on
  peut l'utiliser n'importe quant
=end
require 'cgi'
require 'net/smtp'

class MiniMail
  # ---------------------------------------------------------------------
  #   SYNTAXE
  #     MiniMail.new().send(<message>)
  #
  def send(message, sujet = nil, options = nil)
    options ||= {}
    options[:to]        ||= 'phil@laboiteaoutilsdelauteur.fr'
    options[:from]      ||= 'phil@laboiteaoutilsdelauteur.fr'
    options[:log]       ||= false
    options[:log_error] ||= false
    options[:format]    ||= 'plain'

    # On prend les logs ?
    if options[:log_error]
      message +=
        "\n\n=== LOG ERROR ===\n\n" +
        File.open(error_log_path, 'r'){|f|
          f.read.force_encoding('utf-8')
        } rescue ""
    end
    if options[:log]
      message +=
        "\n\n=== LOG ===\n\n" +
        File.open(safed_log_path, 'r'){|f|
          f.read.force_encoding('utf-8')
        } rescue ""
    end

    # On met en forme le message minimum
    message = <<-MAIL
From: <#{options[:from]}>
To: <#{options[:to]}>
MIME-Version: 1.0
Content-type: text/#{options[:format]}; charset=UTF-8
Subject: #{sujet}

#{message}

    MAIL
    serverfrom = ONLINE ? 'www.laboiteaoutilsdelauteur.fr' : 'localhost'
    Net::SMTP.start(
      data[:server], data[:port], serverfrom,
      data[:user], data[:password]
      ) do |smtp|
        smtp.send_message message, options[:from], options[:to]
    end
  end

  def error_log_path
    @error_log_path ||= "#{THIS_FOLDER}/safed_error_log.log"
  end
  def safed_log_path
    @safed_log_path ||= "#{THIS_FOLDER}/safed_log.log"
  end

  def data
    @data ||= begin
      require File.join(RACINE, 'data', 'secret', 'data_mail.rb')
      MY_SMTP.merge(DATA_MAIL)
    end
  end
end # / MiniMail
