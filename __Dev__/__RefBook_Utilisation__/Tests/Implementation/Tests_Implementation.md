# Implémentation

* [Problèmes à résoudre](#problemearesoudre)
* [Aide pour cUrl](#aidepourcurl)

<a name='problemearesoudre'></a>

## Problèmes à résoudre

PROBLÈME #1  : Le problème que j'ai rencontré était un problème de code HTML (la page complète, en retour d'une requête cUrl) qui n'était pas actualisée. Un premier appel sur `form.exist` vérifiait que le formulaire existait dans la page (en utilisant Nokogiri) puis on appelle une méthode form.fill_and_submit qui est soumise en cUrl et ensuite, la méthode form.has_message travaillait avec le premier code, pas celui retourné par `fill_and_submit`.

> PROBLÈME #2 Note&nbsp;: Ci-dessus, il faudrait régler le problème du `form.has_message` qui n'est pas cohérent. On devrait pouvoir utiliser partout `page.has_message` (ou un autre nom que `page` pour ne pas interférer avec les méthodes existantes)

Pour palier ce problème, j'ai modifié la méthode `execute` de la class `SiteHtml::TestSuite::CURL` en ajoutant&nbsp;:

~~~ruby

    # Dans ./lib/deep/deeper/module/test/request/cUrl.rb
    owner.nokogiri_html= content

~~~

La méthode `nokogiri_html`, ici appartenant à la classe `SiteHtml::TestSuite::Form` par le module `ModuleRouteMethods` (`./lib/deep/deeper/module/test/first_required/module/route_methods.rb`) redéfinit `@nokogiri_html` et surtout initialise `@instance_test_html` qui oblige à réinitialiser l'instance `SiteHtml::TestSuite::Html` qui s'occupe des tests sur le code.


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

Comme ces méthodes peuvent recevoir plusieurs type d'ensemble, il vaut mieux utiliser une seule méthode pour toutes les créer. C'est méthode est la méthode `evaluate_as_pluriel` de la class `DSLTestClass`. Il suffit de faire&nbsp;:

    def has_tags liste, options=nil
      evaluate_as_pluriel :has_tag, liste, options
    end