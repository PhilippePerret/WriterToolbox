# Implémentation

* [Problèmes à résoudre](#problemearesoudre)
* [Aide pour cUrl](#aidepourcurl)

* [Débuggage](#debuggageducode)
<a name='debuggageducode'></a>

## Débuggage

On peut débugguer le code en ajoutant `--debug` à la commande qui lance le test.

Dans les tests-méthodes, on peut utiliser la méthode `html.inspect` pour inspecter le code HTML couramment étudié. Le code est proposé dans le débug.

<a name='problemearesoudre'></a>

## Problèmes à résoudre



---------------------------------------------------------------------

<a name='aidepourcurl'></a>

## Aide pour cUrl

Voir les pages :

* [curl.haxx.se](https://curl.haxx.se/docs/httpscripting.html#Forms_explained)

Cette aide `cUrl` doit permettre de rédiger de nouveaux tests.


        Option -o "un/fichier"
        Pour que la page retournée soit enregistrée dans un fichier
        plutôt que retournée
        Note : -O pour l'enregistrer dans le même nom de page

        Option -I ou --head
        Retourne seulement l'entête (HEADER). Permet de gagner en
        rapidité pour certains tests.

        Option -f
        On peut ajouter `-f` pour que la page d'erreur ne soit
        pas retournée en cas d'erreur (code 22)

        Option -F
        Pour simuler la soumission d'un formulaire
        curl -F "name=\"Son nom\";prenom='Prénom'" example.com
        Fichier uploadé :
        curl -F "web=@index.html;type=text/html" example.com

        req = 'curl -I "http://www.laboiteaoutilsdelauteur.fr/bad/one.htm"'

        res = `curl -I "http://www.laboiteaoutilsdelauteur.fr/bad/one.htm"`


* [Gestion des "méthodes-plurielles"](#gestionmethodeplurielle)
<a name='gestionmethodeplurielle'></a>

## Gestion des "méthodes-plurielles"

Rappel : Une "méthode-plurielle", c'est par exemple la méthode `has_tags` en comparaison avec la méthode `has_tag`.

Comme ces méthodes peuvent recevoir plusieurs type d'ensemble, il vaut mieux utiliser une seule méthode pour toutes les créer. C'est méthode est la méthode `evaluate_as_pluriel` de la class `DSLTestMethod`. Il suffit de faire&nbsp;:

    def has_tags liste, options=nil
      evaluate_as_pluriel :has_tag, liste, options
    end