# Librairies propres à l'application

* [Ajout de librairies application](#ajoutedenouvellelibrairie)
* [Requérir un module du RestSite](#requerirunmoduledurestsite)
* [Requérir un module d'objet](#requerirunmoduleobjet)
  * [Requérir des librairies en premier](#requerirdesmodulesenpremier)
* [Requérir un module de l'application](#requerirunmoduleapplication)

<a name='ajoutedenouvellelibrairie'></a>

## Ajout de librairies application


On peut ajouter des librairies propres à l'application dans le dossier :

    ./lib/app/

Les fichiers sont automatiquement et toujours chargés s'ils se trouvent dans les dossiers :

    ./lib/app/required/   # => chargés chaque fois
    ./lib/app/handy/      # => chargés chaque fois

<a name='requerirunmoduledurestsite'></a>

## Requérir un module du RestSite

> Ce module doit se trouver dans le dossier `./lib/deep/deeper/module`.

~~~ruby

    site.require_module 'nom_du_module'

~~~

<a name='requerirunmoduleapplication'></a>

## Requérir un module de l'application

Cf. [requérir un module d'objet](#requerirunmoduleobjet) puisque ce sont ces modules les modules de l'application.

<a name='requerirunmoduleobjet'></a>

## Requérir un module d'objet

Si l'objet est `MonObjet` et qu'il a été chargé par :

~~~ruby

    site.require_objet 'mon_objet'

~~~

… alors il suffit pour charger un de ses modules de faire :

~~~ruby

    MonObjet::require_module 'mon_module'

~~~

> Ce module doit être défini dans le dossier :

        ./objet/mon_objet/lib/module/

<a name='requerirdesmodulesenpremier'></a>

### Requérir des librairies en premier

Si on doit charger des librairies en premier, il suffit de les placer dans un dossier appelé `first_required` :

        ./objet/mon_objet/lib/module/mon_module/first_required/
        # Les fichiers RUBY de ce dossier seront chargées en premier
        
