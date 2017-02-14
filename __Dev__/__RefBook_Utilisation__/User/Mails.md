# Mails

* [Options pour les mails](#optionspourlesmails)
* [Envoi d'un mail à partir du site normal](#envoidunmaildepuislesite)
* [Envoi d'un mail hors du site normal (cron, etc.)](#envoidunmailhorsistenormal)
* [Gabarit pour les mails](#gabaritpourlesmails)

<a name='optionspourlesmails'></a>

## Options pour les mails

~~~

formated            Si true, le message est considéré comme formaté
                    donc déjà au format HTML.

no_citation         Si true, pas de citation ajoutée au mail

no_footer           Si true, aucun pied de page n'est ajouté. Ce pied de
                    page contient en général les adresses du site.
                    
signature           Si false, la signature n'est pas apposée. Elle doit être
                    dans le message lui-même.

no_header_subject   Si true, on n'ajoute pas le préfixe pour le sujet
                    du message.

force_offline       Si true, on envoie le mail vraiment même si on est
                    en local.

~~~

<a name='envoidunmaildepuislesite'></a>

## Envoi d'un mail à partir du site normal

> Note : Ce que j'appelle ici le "site normal", c'est lorsqu'on est dans une utilisation normale du site, quand toutes les librairies sont chargées et que la variable `site` est définie. Ça n'est pas le cas par exemple lorsque c'est le CRON qui travaille.

Pour envoyer un mail à un user quelconque :

    site.send_mail(<{hash data_mail}>)

où `data_mail` définit `:from`, `:to`, `:subject` et `:message`. Il peut aussi définir `formated: true` si le message est déjà formaté.

Si l'user est identifié, on peut utiliser :

    user.send_mail(<data_mail>)

avec `data_mail` qui peut alors ne pas contenir `:to` ni `:from` (qui sera mis à l'adresse du site défini dans les configurations par `site.mail = ...`)

<a name='envoidunmailhorsistenormal'></a>

## Envoi d'un mail hors du site normal (cron, etc.)

C'est trop compliqué de faire. Le plus simple est de charger toutes les librairies du site (./lib/required) et d'utiliser la méthode normale.

<a name='gabaritpourlesmails'></a>

## Gabarit pour les mails

On peut trouver tout ce qui concerne les mails dans le dossier :

    ./lib/deep/deeper/optional/Site/mail

Il faut modifier les méthodes du fichier `custom.rb` pour modifier l'aspect du mail.
