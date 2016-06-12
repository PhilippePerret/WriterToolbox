# Procédurier

Ce fichier contient la description de toutes les procédures d'administration de la boite à outils de l'auteur.

* [Nouvel article de blog](#nouvelarticle)


<a name='nouvelarticle'></a>

## Nouvel article de blog

* Créer le fichier dans le dossier `./objet/article/lib/texte/` en lui donnant le numéro voulu (aucun si c'est un brouillon)
* Quand l'article est prêt, le faire lire à Marion en l'affichant et en choisissant “Marquer à relire (par lecteurs)” dans le menu des tâches (en haut à gauche de toute page),
* Quand l'article est corrigé et doit être publié, indiquer son numéro dans `./objet/article/current.rb`
* [Faire un lien bitly](https://app.bitly.com/bitlinks/1TkHhvC) en copiant-collant son lien permanent,
* Faire une nouvelle UPDATE depuis la console (taper simplement “update” + tab, indiquer comme message “Nouvel article : SON TITRE”, annonce:1),
* Faire une synchronisation depuis le dashboard,
* Faire une synchronisation depuis la console (`check synchro`),
* Envoyer un tweet pour annoncer le nouvel article avec son titre et le lien bitly (`twit ` + message dans la console),
* Le lendemain, faire une annonce sur Facebook avec le début de l'article.
