# Mail à l'administration

* [Envoi d'un mail à l'administration](#envoyermailaadministration)
* [Envoi d'un mail en cas d'erreur](#envoimailencasderreur)


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

<a name='envoimailencasderreur'></a>

## Envoi d'un mail en cas d'erreur

Pour envoyer un mail en cas d'erreur, on peut utiliser la méthode :

    send_error_to_admin <args>

(définie dans ./lib/deep/deeper/required/divers/handy.rb)

`args` peut contenir :

    :exception        L'erreur, le 'e' de `rescue Exception => e`
    :from             Un message humain pour dire d'où vient l'erreur, où
                      elle a été produite
    :url              Optionnellement, et si connue, l'url d'erreur
    :file             Optionnellement, et si connu, le fichier pour lequel
                      s'est produite l'erreur.

La méthode ajoute l'user qui a rencontré l'erreur s'il existe.
