# Description

Encore un programme pour site pour essayer de faire quelque chose d'encore plus pratique pour créer rapidement des applications.

Ce site est RestFull, c'est-à-dire qu'il fonctionne à base d'adresses de type :

    http://<base>/<objet>[/<id>]/<method>

… pour le commander. Par exemple, pour afficher le profil d'un utilisateur, on fait :

    http://mon_site/user/12/profil

On obtient l'objet dans `__o`, l'identifiant (if any) dans `__i` et la méthode dans `__m`.

## L'objet

L'objet doit être un objet défini (par exemple `User` ou `Page`) ou un objet propre à l'application, se trouvant dans le dossier `objet`.

## Hiérarchie de l'application

On part du principe qu'une application est constitutée de pages, c'est donc l'objet principal. Les pages sont définies dans le dossier :

    ./page/

Mais l'application gère les objets et donc on trouve le dossier :

    ./objet/

… où sont définis tous les objets propres à l'application.
