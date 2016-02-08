#CRON-JOB

* [Fichier log sûr](#fichierlogsure)


Ce fichier décrit le travail du cron-job qui suit les auteurs suivant le programme UN AN UN SCRIPT.

Tous les éléments du cron-job se trouvent dans le dossier `./CRON` qui doit être placé à la racine complète de l'hébergement (pas du site, donc avant le `www`).

Le cron est lancé par la ligne de commande :

    0 * * * * ruby ./CRON/hour_cron.rb > /dev/null

C'est le fichier `hour_cron.rb` qui est le fichier `main.rb`.

Ce fichier appelle le module `./lib/required.rb`.

    ./hour_cron.rb -> ./lib/required.rb

Le fichier `./lib/required.rb` charge des librairies de cron puis appelle la méthode générale :

    Cron::run


<!-- --------------------------------------------------------------------- -->

<a name='fichierlogsure'></a>

## Fichier log sûr

Pendant tout le processus, on peut utiliser la méthode :

  safed_log message

… pour enregistrer un message qui le sera à tout moment.
