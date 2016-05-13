# Tests

* [Introduction](#introductionteststest)
* [Hiérarchie des éléments](#hierarchiedeselements)
* [Messages de succès ou de failure](#ajoutermessagefailuresuccess)
* [Méthodes du module `ModuleRouteMethods`](#methodesmoduleroutemethodes)
* [Les méthodes de test](#lesmethodesdetests)
  * [Options de dernier agument de méthode-test](#optionsdefinmethodestest)
  * [Méthodes-case `methode`, `not_methode` et `methode?`](#hashashnotandinterrogation)
  * [Méthodes-case de l'objet-case ROUTE](#methodesdetestderoute)
  * [Méthodes-case de l'objet-case FORM](#methodesdetestsdeformulaire)

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

Négatif : `not_responds`

Sans évaluation : `responds?`

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


<a name='hashashnotandinterrogation'></a>

### Méthodes-case `methode`, `not_methode` et `methode?`

La plupart des méthodes de test possèdent trois états différents qui correspondent à trois actions et retours différents :

La méthode "droite" ou "test-case"
: C'est la méthode qui produit une évaluation, donc un succès ou une failure.
: Par exemple : `has_titre`

La méthode "inverse"
: La méthode inverse fait le contraire de la méthode droite. Un "not" est ajouté à son nom.
: Par exemple : `has_not_titre`

La méthode "interrogation"
: La méthode "interrogation" ne produit pas d'évaluation, elle retourne simplement `false` ou `true` en fonction du résultat.
: Par exemple : `has_titre?`


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
* [`fill_and_submit` - remplissage du formulaire](#testremplissageformulaire)

<a name='testexistenceformulaire'></a>

#### `exist` - Test de l'existence du formulaire

~~~ruby

    test_form "mon/formulaire", data do |f|
      f.exist
    end
~~~

Négatif&nbsp;: `not_exist`

Sans évaluation&nbsp;: `exist?`

<a name='testremplissageformulaire'></a>

#### `fill_and_submit` - remplissage et soumission du formulaire

~~~ruby

    test_form "mon/formulaire", data_form do |f|

      f.fill_and_submit

    end
~~~

Données de formulaire :

~~~ruby
  data_form = {
  
    id: "ID du formulaire",
    action: "ACTION/DU/FORMULAIRE", 
    fields: {
      <field_id>: {name: <field[name]>, value:"<field_value_expected_or_send>"},
      <field id>: {name: <field[name2]>, value:"<field value expected or send>"},
      etc.
    }
  }
~~~

> Note : La propriété `:name` est impérative pour les champs s'ils doivent être pris en compte pour la simulation de remplissage.

Les données utilisées seront celles transmises dans `data_form` (enregistrées à l'instanciation du formulaire) mais on peut également en transmettre d'autres à la volée qui seront mergées DE FAÇON INTELLIGENTE (*) avec les données originales. Par exemple :

~~~ruby

    test_form "signup", data_signup do |f|

      f.fill_and_submit(pseudo: nil) # le :pseudo sera mis à nil
      f.has_error "Vous devez soumettre votre pseudo"

      ...

      f.fill_and_submit(password_confirmation: nil)
      f.has_error "La confirmation du mot de passe est requise."

~~~

(*) *DE FAÇON INTELLIGENTE* signifie qu'on peut définir simplement la valeur d'un champ sans mettre `dform[:fields][:id_du_field][:value] = "la valeur"`. Il suffit de faire :

    id_du_field: "la valeur"
    
… et la méthode `fill_and_submit` comprendra qu'il s'agit du champ.
