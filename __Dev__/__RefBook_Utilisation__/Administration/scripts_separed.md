# Script autonome

* [Dossier des scripts utiles](#dossierdesscriptsutiles)
* [Requérir toutes les librairies](#requerirlibrairies)
* [Exécuter un script comme administrateur](#executerscriptcomeadmin)

<a name='dossierdesscriptsutiles'></a>

## Dossier des scripts utiles


Utiliser le dossier :

        ./__Dev__/_Usesull_/

… pour mettre des scripts à lancer seuls sur le site.

<a name='requerirlibrairies'></a>

## Requérir toutes les librairies

Pour réquérir toutes les librairies du site, il suffit d'ajouter la ligne :

        require './lib/required'

<a name='executerscriptcomeadmin'></a>

## Exécuter un script comme administrateur

Pour exécuter un script comme administrateur, ajouter simplement au-dessus du module :

        require './lib/required'
        User::current = User::get(1)
        app.session['user_id'] = 1
