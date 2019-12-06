# Twitter

* [Envoi d'un message sur twitter](#envoidunmessagetwitter)
* [Les “Tweets permanents”](#messagespermanents)
  * [Création d'un tweet permanent](#creationduntweetpermanent)
  * [Table des Tweets permanents](#tabledestweetspermanent)
  * [Cron-job pour les tweets permanent](#cronjobpourlescitations)
* [Dossier du module Twitter](#dossiermoduletwitter)


<a name='envoidunmessagetwitter'></a>

## Envoi d'un message sur twitter


        site.require_module 'twitter'
        site.tweet "le message à envoyer"

* [Information sur le compte](#informationsurlecompte)
<a name='informationsurlecompte'></a>

## Information sur le compte

Le compte s'appelle :

        #b_outils_auteur

Les données secrètes sont enregistrées dans :

        ./data/secret/data_twitter.rb


<a name='messagespermanents'></a>

## Les “Tweets permanents”

Les “tweets permanents” sont des tweets qui sont enregistrés et envoyés régulièrement sur twitter. Ils permettent de maintenir un flux, une présence sur twitter.

La plupart du temps, ces tweets sont composés de :

    “Une citation extraite d'une page” bit.ly/lienbitly

<a name='creationduntweetpermanent'></a>

### Création d'un tweet permanent

Un tweet permanent se crée comme un autre tweet mais on ajoute simplement `P` entre la commande et le message :

    $> twit P “La citation” bitly/...

La console reconnait alors un lien permanent et l'enregistre dans la table des liens permanent.

<a name='tabledestweetspermanent'></a>

### Table des Tweets permanents

Cette table s'appelle `permanent_tweets` et est consignée dans la base `scenariopole_cold`.

Cette table n'est pas synchronisée car on ne peut envoyer des tweets permanent qu'en online.

<a name='cronjobpourlescitations'></a>

### Cron-job pour les tweets permanent

Le cron-job s'occupe d'envoyer régulièrement sur Twitter des tweets permanents.

Il utilise pour ça la méthode de classe :

    SiteHtml::Tweet::auto_tweet[ <nombre de tweet>]

Plus la table contiendra de tweets et plus on pourra en envoyer régulièrement, jusqu'à 2 toutes les heures.

La **fréquence des tweets** est déterminée par la constante `PERMANENT_TWEET_FREQUENCE` et le **nombre de tweets à envoyer** par `NOMBRE_PERMANENT_TWEETS_SEND`. Les deux constantes sont définies dans le fichier :

    ./CRON/lib/required/Site/permanent_tweet.rb

---------------------------------------------------------------------

<a name='dossiermoduletwitter'></a>

## Dossier du module Twitter

Le dosssier du module `Twitter` se trouve à :

    ./lib/deep/deeper/module/twitter
