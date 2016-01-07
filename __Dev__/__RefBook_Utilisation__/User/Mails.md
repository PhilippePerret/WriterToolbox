# Mails

* [Envoi d'un mail](#envoiedunmail)
* [Gabarit pour les mails](#gabaritpourlesmails)

<a name='envoiedunmail'></a>

## Envoi d'un mail


Pour envoyer un mail à un user quelconque :

    site.send_mail(<{hash data_mail}>)

où `data_mail` définit `:from`, `:to`, `:subject` et `:message`. Il peut aussi définir `formated: true` si le message est déjà formaté.

Si l'user est identifié, on peut utiliser :

    user.send_mail(<data_mail>)

avec `data_mail` qui peut alors ne pas contenir `:to` ni `:from` (qui sera mis à l'adresse du site défini dans les configurations par `site.mail = ...`)


<a name='gabaritpourlesmails'></a>

## Gabarit pour les mails

Aucun gabarit n'est encore utilisé pour les mails, mais la procédure sera implémentée bientôt.
