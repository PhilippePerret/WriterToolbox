# CRON-JOB

* [Description de Cron::run](#descriptioncronrun)
* [Traitement des programmes un an un script](#traitementprogrammesunanunscript)
* [Traitement des messages du forum](#traitementmessagesforum)

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

<a name='descriptioncronrun'></a>

## Description de Cron::run

Le Cron se place sur la racine du site.

Il charge toutes les librairies du site, comme si on chargeait la page.

Il appelle ensuite la méthode `traitement_programme_un_an_un_script` qui va se charger du traitement des programmes UN AN UN SCRIPT. Cf. [Traitement des programmes un an un script](#traitementprogrammesunanunscript)

Il appelle ensuite la méthode `traitement_messages_forum` qui va se charger du traitement des messages de forum, pour avertir des nouvelles publications. Cf. [Traitement des messages du forum](#traitementmessagesforum)


<a name='traitementprogrammesunanunscript'></a>

## Traitement des programmes un an un script

Cf. le fichier RefBook/Program/Cron_job_horaire.md

<a name='traitementmessagesforum'></a>

## Traitement des messages du forum




<!-- --------------------------------------------------------------------- -->

<a name='fichierlogsure'></a>

## Fichier log sûr

Pendant tout le processus, on peut utiliser la méthode :

  safed_log message

… pour enregistrer un message qui le sera à tout moment.
