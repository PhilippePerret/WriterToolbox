# encoding: UTF-8
=begin

Extension User pour le travail du cron
Inaugurée pour gérer les mails envoyés à l'user, sauf le mail
de changement de jour-programme qui possède sa propre classe

=end
class User

  attr_reader :messages_mail
  attr_reader :alertes_mail

  # Envoi un message à l'utilisateur après le travail du cron, mais
  # seulement si des messages sont à lui transmettre.
  def send_mail_if_needed
    # S'il n'y a ni messages ni alerte, on peut s'en retourner sans
    # rien faire.
    return if messages_mail.nil? && alertes_mail.nil?
    # Sinon, on compose le message du mail et on l'envoie
    ( send_mail data_mail_cron )
    log "--- Mail envoyé à #{pseudo} (##{pseudo}) pour lui signaler des erreurs ou des notes."
    # Après cet envoi, on initialise les données principales, pour
    # qu'un autre mail puisse lui être envoyé, sans redondance
    @messages_mail  = nil
    @alertes_mail   = nil
  end

  # Données pour le mail pour le travail du cron
  def data_mail_cron
    {
      subject: "Messages de l'administration",
      message: message_cron_job
    }
  end

  # Retourn le code HTML/mail pour le message du mail qui doit
  # être envoyé à l'auteur.
  def message_cron_job
    c = ""
    c << "Bonjour #{pseudo},".in_p
    unless alertes_mail.nil?
      c << "Des problèmes ont été décelés sur votre compte.".in_p(class:'warning')
      c << alertes_mail.collect{ |m| m.in_li }.join.in_ul(class:'warning')
    end
    unless messages_mail.nil?
      c << messages_mail.collect{|m| m.in_li}.join.in_ul
    end
    return c
  end

  def add_alerte_mail mess_alerte
    @alertes_mail ||= Array::new
    @alertes_mail << mess_alerte
  end

  def add_message_mail mess_mail
    @messages_mail ||= Array::new
    @messages_mail << mess_mail
  end


end #/User
