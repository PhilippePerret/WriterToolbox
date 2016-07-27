# CRON2

* [Message Super-log](#envoimesssagesuperlog)


<a name='envoimesssagesuperlog'></a>

## Message Super-log

Les `messages super-log` sont des messages d'importance qui sont envoyés suite au travail complet du CRON. Il faut en mettre le moins possible et aucun détail, juste le résultat.

Ils ont été inaugurés pour signaler un auteur du programme UNAN qui aurait trop de dépassements et de travaux non démarrés.

On ajoute un message `super-log` simplement en faisant :

    superlog "<message>"[, <options>]

*(note : les options ne sont pas encore utilisées.)*
