# encoding: UTF-8
=begin

  Méthodes générales pratiques

=end

# Permet d'envoyer un message à l'admininistrateur suite à une
# erreur.
#
# +args+
#   :exception      L'erreur complète rencontrée, avec #message et
#                   # backtrace
#   :url            L'url, if any.
#   :file           Le path du fichier qui a posé problème, if any
#   :from           La provenance de l'erreur, même si elle peut
#                   être retrouvée dans backtrace
def send_error_to_admin args
  err = args[:exception]
  message = <<-HTML
<p>Erreur sur #{site.name}</p>
<p>
  Date : #{Time.now.to_i.as_human_date(true, true, ' ', 'à')}
</p>
<p>
  User : #{user.identified? ? "#{user.pseudo} (#{user.id})" : '- inconnu -'}
</p>
<pre style="font-size:11pt">
  MESSAGE : #{err.message}
  BACKTRACE
  #{err.backtrace.join("\n")}
</pre>
  HTML
  # Ajout des informations supplémentaires
  if args[:from]
    message += "Cette erreur a été rencontrée depuis : #{args[:from]}".in_p
  end
  if args[:file]
    message += "Erreur rencontrée sur le fichier : #{args[:file]}".in_p
  end
  if args[:url]
    message += "Erreur rencontrée avec l'URL : #{args[:url]}".in_p
  end

  site.send_mail_to_admin(
    subject:    "ERREUR SUR #{site.name}",
    message:    message,
    # force_offline:  true, # pour les essais
    formated:   true
  )
end
