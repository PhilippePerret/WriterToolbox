# Tests

* [Introduction](#introductionteststest)
* [Hiérarchie des éléments](#hierarchiedeselements)
* [Implémentation du test](#implementation_du_test)
* [Liste des méthodes de test](#listemethodesdetest)
  * [Méthode de test `test_route`](#methodetesttestroute)
  * [Méthode de test `test_form`](#methodedetesttestform)



* [Méthodes du module `ModuleRouteMethods`](#methodesmoduleroutemethodes)
* [Les méthodes de test](#lesmethodesdetests)
  * [Options de dernier agument de méthode-test](#optionsdefinmethodestest)
  * [Méthodes-case `methode`, `not_methode` et `methode?`](#hashashnotandinterrogation)
  * [Méthodes-case de l'objet-case ROUTE](#methodesdetestderoute)
  * [Méthodes-case de l'objet-case FORM](#methodesdetestsdeformulaire)

Deux formes de tests sont possibles :

* les tests `RSpec` traditionnels. Cf. le fichier `RSpec.md`,
* les tests propres à RestSite.

Ce document ne décrit que les seconds tests.

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

<a name='implementation_du_test'></a>

## Implémentation du test

Un test se crée dans une “feuille de test”.

* Créer la feuille de test (le fichier) dans un sous-dossier du dossier `./test`&nbsp;;
* choisir la “méthode-test” à utiliser (il peut y en avoir plusieurs par feuille de test). Par exemple&nbsp;:

        test_route "une/route" do
        
        end
        
    Vous pouvez trouver dans ce document la [liste de toutes les méthodes de test](#listemethodesdetest).
* une description par défaut existe pour toutes les méthodes de test mais on peut définir une description plus appropriée à l'aide de `description`&nbsp;:

        test_route "une/route" do
          description "Ceci est un test de la route “une/route”"
          
        end

---------------------------------------------------------------------


<a name='listemethodesdetest'></a>

## Liste des méthodes de test

Les “méthodes de test” sont les objets supérieurs des feuilles de test.



<a name='methodetesttestroute'></a>

### Méthode de test `test_route`

Pour tester une route, donc une adresse URL et la page retournée.

@usage

    test_route <route>[, <option>] do
      <test>
      <test>
      ...
    end
    
@exemple

    test_route "" do
      description "Le test de la page d'accueil du site"
      html.has_titre("Bienvenue&nbsp;!", niveau: 1)
    end
    
<a name='methodedetesttestform'></a>

### Méthode de test `test_form`

Permet de tester la soumission d'un formulaire.

@usage

    test_form <route>, <data formulaire>[, options] do
      <test>
      <test>
      ...
    end

@exemple

    test_form "user/login", data_login do
      description "Un user peut s'identifier avec des données valides"
      fill_and_submit
      ...
    end

Noter que puisque cette méthode de test hérite des méthodes de test de la route, on peut aussi bien tester la validité du formulaire en lui-même —&nbsp;en tant qu'objet DOM&nbsp;— que son efficacité lorsqu'on le soumet avec des données valides ou non. 

Mais noter qu'il peut s'agir de deux routes différentes. Par exemple, pour un `RestSite` classique, on utilise la route `user/signin` pour atteindre le formulaire d'identification tandis qu'on utilise la route `user/login` pour identifier l'user en soumettant ce questionnaire. Donc on aura&nbsp;:

    test_form "user/signin", data_form do
      # Test de la conformité du formulaire affiché
      # La donnée +data_form+ permet de voir les champs à tester
    end
    
    test_form "user/login", data_form do
      # Test du résultat du login, c'est-à-dire du contenu de la page
      # et autre effet après soumission du formulaire avec les données
      # contenues dans +data_form+
      
    end



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
