* [Envoi d'un mail à l'administration](#envoyermailaadministration)
<a name='envoyermailaadministration'></a>

## Envoi d'un mail à l'administration

Pour envoyer un mail à l'administration, on utilise la même méthode que pour n'importe quel envoi :

        site.send_mail <data mail>

… à la différence près qu'on n'indique pas de `:to` (le `:from` peut être mis à l'user qui est connecté if any) :

        data_mail ={
          subject:  "<le sujet>",
          message:  "<le message>",
          formated: true # si le message est formaté
          from:     user.mail # si un user courant existe
        }
        site.send_mail(data_mail)

Le message sera automatiquement transmis à l'adresse définie dans `site.mail` dans le fichier de configuration `config.rb`.
