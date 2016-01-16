# Synopsis d'un auteur

* [Démarrage du programme UN AN UN SCRIPT](#demarrageduprogramme)
* [Changement des jours-program](#changementdesjoursprogramme)


<a name='demarrageduprogramme'></a>

## Démarrage du programme UN AN UN SCRIPT

Un programme UN AN UN SCRIPT se démarre lorsque l'auteur s'inscrit au programme, c'est-à-dire au moment précis où il revient du site PayPal après le paiement de son inscription.

> Note : Le montant de ce paiement est défini dans le fichier `./objet/unan/lib/required/unan/class.rb` dans la méthode `tarif`.

*Vue et module `on_ok`*

Il passe alors par la vue `./objet/unan/paiement/on_ok.erb` et le module `./objet/unan/paiement/on_ok.rb`.

*Module signup_user.rb*

on_ok.rb charge le module `./objet/unan/lib/module/signup_user.rb` et appelle dans ce module la méthode `User#signup_program_uaus`.

*signup_program_uaus*

Cette méthode :

* Crée le programme UN AN UN SCRIPT de l'auteur
* Crée le projet de l'auteur
* Crée ses tables dans la base de données propre au programme (chaque programme possède sa propre base de données, même lorsqu'il est suivi par le même auteur).
* Instancie le premier "jour-programme" de l'auteur, ce qui va avoir pour conséquence de définir son travail (cf. program.start_pday ci-dessous).
* Envoie les messages de confirmation d'inscription, de premières explications, etc. à l'auteur et d'avertissement à l'administration.

<a name='changementdesjoursprogramme'></a>

## Changement des jours-program

Tous les jours-programme, donc tous les jours pour un rythme de 5 et plus ou moins un jour réel pour les autres rythmes, le jour-programme des auteurs change.

Ce changement est produit par un cron-job qui travaille toutes les heures.

*Program#start_pday*

C'est la méthode appelée pour démarrer un nouveau jour de travail.

> Noter que cette cette méthode qui est appelée au tout premier démarrage du programme (après le paiement).

Cette méthode lit l'instance `AbsPDay` du jour-programme concerné qui contient notamment la liste des tous les travaux (`AbsWork`) à effectuer. Elle dispatche ces travaux dans les variables correspondantes de l'auteur pour qu'elles puissent être affichées dans son bureau principal de travail.
