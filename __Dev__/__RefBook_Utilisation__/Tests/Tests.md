# Tests

* [Introduction](#introductionteststest)
* [Hiérarchie des éléments](#hierarchiedeselements)
* [Messages de succès ou de failure](#ajoutermessagefailuresuccess)
* [Méthodes du module `ModuleRouteMethods`](#methodesmoduleroutemethodes)
* [Les méthodes de test](#lesmethodesdetests)
  * [Options de dernier agument de méthode-test](#optionsdefinmethodestest)
  * [Méthodes-case de l'objet-case ROUTE](#methodesdetestderoute)
  * [Méthodes-case de l'objet-case FORM](#methodesdetestsdeformulaire)
* [Aide pour cUrl](#aidepourcurl)

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

        SiteHtml::TestSuite::File::Test    METHODE-TEST
            Une instance de test, un cas, ce qui appelé un
            "example" par RSpec, c'est que j'appelle une
            methode-test.
            Une méthode-test travaille le plus souvent avec un
            OBJET-CASE (ça peut être une route, un formulaire, etc.)
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

---------------------------------------------------------------------


<a name='methodesmoduleroutemethodes'></a>

## Méthodes du module `ModuleRouteMethods`

* [respond](#methoderesponds)
* [has_title](#methodehastitle)
* [has_tag](#methodtesthastag)


<a name='methoderesponds'></a>

#### `responds`

Retourne très si la commande renvoie une page valide (code 200)

        responds

Négatif :

        not_responds


<a name='methodehastitle'></a>

#### `has_title`

Produit un succès si la page contient le titre spécifié, au niveau spécifié (if any)

@syntaxe

        has_title <titre>[, <niveau>][, <options>]

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




---------------------------------------------------------------------


<a name='lesmethodesdetests'></a>

## Les méthodes de test


---------------------------------------------------------------------

<a name='optionsdefinmethodestest'></a>

### Options de dernier agument de méthode-test

On peut trouver en dernier argument des méthodes-test l'argument `options` qui permet de définir plusieurs choses. Par exemple :

~~~ruby

    test_form "user/login", dataform, "Test du login" do |f|
      ...
~~~

Ci-dessus, c'est "Test du login" qui sera la valeur de `options` dans :

~~~ruby

    def test_form route, data = nil, options = nil
      ...
    end

~~~

Ce dernier argument peut être :

* Un `String`. Dans ce cas, c'est simplement le libellé à donner au test dans le rapport.
* Un `Hash` qui peut contenir ces valeurs :

        libelle:      {String} "Le libellé du test"
        line:         {Fixnum} Le numéro de ligne du test dans sa
                      feuille de test (qu'on peut obtenir par __LINE__)
                      
---------------------------------------------------------------------

<a name='methodesdetestderoute'></a>


### Méthodes de tests de route (méthodes-cases)

Ce que j'appelle les "méthodes de tests de route", ce sont les méthodes qui testent une page particulière appelée par une route, donc une URL moins la partie local.

Par exemple, si l'url complète est `http://www.atelier-icare.net/overview/temoignages` alors la route est `overview/temoignagnes`. Cette route peut également définir des variables après un "?".

La formule de base du test d'une route est la suivante :

        test_route "la/route?var=val"[, options] do |r|
          r.<methode>
          r.<methode> <parametres>
        end

`options` peut être le libellé à donner au test (`String`) ou un `Hash` contenant : les [options de fin de méthode](#optionsdefinmethodestest)

Liste des méthodes :

Cet objet-test hérite de toutes les [méthodes du module `ModuleRouteMethods`](#methodesmoduleroutemethodes)

---------------------------------------------------------------------

<a name='methodesdetestsdeformulaire'></a>

## Méthodes-cases de l'objet-case formulaire

L'autre grande chose à faire avec les pages, c'est le remplissage de formulaires. La méthode-test ci-dessous est la méthode principale qui s'en charge :

        test_form "la/route", <data> do |f|

          f.<methode>

        end

Les `data` doivent permettre de trouver le formulaire et de remplir les champs du formulaire avec les valeurs proposées, sous la forme :

        {
          id:     "ID du formulaire (if any)",
          name:   "NAME du formulaire (if any)",
          action: "ACTION du formulaire, if any",
          fields: { # Champs du formulaire
            'id ou name de champ' => {value: <valeur à donner> },
            'id ou name de champ' => {value: <valeur à donner> }            
          }
        }

Toutes les méthodes-cases :

Toutes les [méthodes du module `ModuleRouteMethods`](#methodesmoduleroutemethodes)
* [`exist` - test de l'existence du formulaire](#testexistenceformulaire)
* [`fill` - remplissage du formulaire](#testremplissageformulaire)

<a name='testexistenceformulaire'></a>

#### `exist` - Test de l'existence du formulaire

~~~ruby

    test_form "mon/formulaire", data do |f|
      f.exist
    end
~~~

<a name='testremplissageformulaire'></a>

#### `fill` - remplissage du formulaire

~~~ruby

    test_form "mon/formulaire", data_form do |f|

      f.fill

    end
~~~

Les données utilisées seront celles transmises dans `data_form` (enregistrées à l'instanciation du formulaire) mais on peut également en transmettre d'autres à la volée qui seront mergées avec les données originales. Par exemple :

~~~ruby

    test_form "signup", data_signup do |f|

      f.fill(pseudo: nil, submit: true)
      f.has_error "Vous devez soumettre votre pseudo"

      ...

      f.fill(password_confirmation: nil, submit: true)
      f.has_error "La confirmation du mot de passe est requise."

~~~

---------------------------------------------------------------------

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
