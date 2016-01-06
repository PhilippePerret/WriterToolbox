# encoding: UTF-8

class SiteHtml

  # Envoi d'un mail
  # @usage
  #   site.send_mail({
  #     to:     <mail receveur>,
  #     from:   <mail expéditeur>,
  #     subject:  "<le sujet>",
  #     message:  "<le message>"
  #   })
  #
  def exec_send_mail data_mail
    debug "data mail :#{data_mail}"
    Mail::new(data_mail).send
  rescue Exception => e
    error e.message
  else
    true # pour confirmer l'envoi
  end

end
