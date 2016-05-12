# Tests

* [Introduction](#introductionteststest)
* [Hiérarchie des éléments](#hierarchiedeselements)
* [Messages de succès ou de failure](#ajoutermessagefailuresuccess)
* [Méthodes de tests de route](#methodesdetestderoute)

Deux formes de tests sont possibles :

* les tests `RSpec` traditionnels. Cf. le fichier `RSpec.md`,
* les tests propres à RestSite.

<a name='introductionteststest'></a>

## Introduction

Les tests non rspec servent principalement à tester l'application en intégration, par exemple :

* vérifier qu'une page renvoie un code, et un code valide,
* soumettre un formulaire et tester le retour/résultat,
* faire un essai de l'api.

<a name='hierarchiedeselements'></a>

## Hiérarchie des éléments


        SiteHtml::TestSuite
            Une instance est une suite de test
            qui est composée de "files" :

        SiteHtml::TestSuite::File
            Une instance de fichier de test
            qui est composée de "tests" :

        SiteHtml::TestSuite::File::Test
            Une instance de test, un cas, ce qui appelé un
            "example" par RSpec
            qui utilise des méthodes qui produisent des "cases" :

        SiteHtml::TestSuite::Case

          Certains `cases` font appels à des gérants de code
          HTML (bout de code ou pages entières)

        SiteHtml::TestSuite::Html

            Et des instances de requête cUrl (mais maintenant
            j'utilise plutôt Nokogiri, qui semble plus rapide,
            SiteHtml::TestSuite::Html utilise Nokogiri)

        SiteHtml::TestSuite::Request

<a name='ajoutermessagefailuresuccess'></a>

## Messages de succès ou de failure

Pour ajouter des messages, utiliser les méthodes :

        test_success <args>

        test_failure <args>

Où `args` est un `Hash` contenant :

        message:      Le message d'erreur ou de succès à afficher
        test_name:    Le nom du test
        test_line:    [optionnel] La ligne du test
        itest:        [optionnel] L'instance SiteHtml::Test du test
                      Par défaut, le test courant (rappel : un test,
                      ici, c'est un fichier, ça n'est pas à confondre avec
                      le "Case", le cas.

<a name='methodesdetestderoute'></a>


## Méthodes de tests de route

* [respond](#methoderesponds)
* [has_title](#methodehastitle)
* [has_tag](#methodtesthastag)

La formule de base du test d'une route est la suivante :

        test_route "la/route?var=val"[, __LINE__] do |r|
          r.<methode>
          r.<methode> <parametres>
        end

<a name='methoderesponds'></a>

#### `responds`

Retourne très si la commande renvoie une page valide (code 200)

        r.responds

Négatif :

        r.not_responds


<a name='methodehastitle'></a>

#### `has_title`

Produit un succès si la page contient le titre spécifié, au niveau spécifié (if any)

@syntaxe

        r.has_title <titre>[, <niveau>][, <options>]

Négatif :

        has_not_title

<a name='methodtesthastag'></a>

#### `has_tag`

Produit un succès si la page contient le tag spécifié.

@syntaxe

        r.has_tag <tag>[, <options>]

Négatif :

        has_not_tag


@exemples

        r.has_tag "div#mondiv.soncss"

        r.has_tag "div", {id:"mondiv", class:'soncss'}

        r.has_not_tag "span", {text: /Bienvenue !/}


* [Aide pour cUrl](#aidepourcurl)
<a name='aidepourcurl'></a>

## Aide pour cUrl

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
