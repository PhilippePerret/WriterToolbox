# Cron job

* [Message à un auteur](#messagesaunauteur)

Toutes les heures, un cron-job est lancé, principalement pour gérer le programme UN AN UN SCRIPT (et voir si des utilisateurs/auteurs doivent être passés au jour suivant).

Mais ce cron sert aussi à d'autres choses, notamment à gérer les messages du forum, pour avertir les inscrits qui suivent certains sujets d'être prévenus.

<a name='messagesaunauteur'></a>

## Message à un auteur

On peut utiliser plusieurs méthodes pour gérer les envois de messages à un user :

    user#add_alerte_mail <alerte>

        Pour ajouter le message d'alerte +alerte+ à l'auteur

    user#add_message_mail <message>

        Pour ajourter le simple message +message+ dans un mail envoyé à l'auteur.

Noter que ces messages ne sont envoyés que s'ils existent (sic), c'est-à-dire qu'aucun mail n'est envoyé à l'user si aucun message n'est à lui envoyé. On utilise pour ça la méthode :

    User#send_mail_if_needed

… spécialement implémentée pour le cron (cf. `CRON/lib/required/User/mail.rb`).

Noter également que pour le moment, ce message n'est envoyé (appel à la méthode `user.send_mail_if_needed`) que dans le traitement des auteurs UN AN UN SCRIPT.
