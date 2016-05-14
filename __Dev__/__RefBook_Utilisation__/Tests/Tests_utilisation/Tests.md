# Tests

* [Introduction](#introductionteststest)
* [Hiérarchie des éléments](#hierarchiedeselements)
* [Implémentation du test](#implementation_du_test)
* [Liste des méthodes de test](#listemethodesdetest)
  * [Méthode de test `test_route`](#methodetesttestroute)
  * [Méthode de test `test_form`](#methodedetesttestform)
* [Méthodes du module `ModuleRouteMethods`](#methodesmoduleroutemethodes)
* [Les méthodes de test](#lesmethodesdetests)
  * [Options de dernier argument de méthode-test](#optionsdefinmethodestest)
  * [Méthodes-case `methode`, `not_methode`, `methode?` et `methodeS`](#hashashnotandinterrogation)
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

    Fichier de test     test-file     contient des :
    Méthodes de test    test-methods  contient des :
    Méthodes de cas     case-method
    
    Par exemple, le fichier de test :
    
        # ./test/mini/login_spec.rb
    
    … contient la méthode de test :
    
        test_form "user/signin", fdata do
          ...
        end
    
    … qui contient la méthode de cas `responds` :
    
        test_form "user/signin", fdata do
          responds
        end
        
    Les fichiers de tests
          … sont définis dans le dossier ./test/
    Les méthodes de test
          … sont définis dans le fichier :
                      ./lib/deep/deeper/module/test/TestFile/test_methods.rb
                      (donc pour la class SiteHtml::TestSuite::TestFile)
          … et définissent leur classe dans leur dossier :
                      ./lib/deep/deeper/module/test/Test_methods/<test method>/
          (cf. le fichier Tests_implementation.md pour le détail)
    Les méthodes de case
          … sont définis dans un fichier `case_methods.rb` dans le dossier
          de leur méthode de test :
                      ./lib/deep/deeper/module/test/Test_methods/<test method>/

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

          Les méthodes de cas (ou "method-case") sont des sous-éléments
          des méthodes de tests.
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

* Créer la feuille de test (le fichier) dans un sous-dossier du dossier `./test` ;
* choisir la “méthode-test” à utiliser (il peut y en avoir plusieurs par feuille de test). Par exemple :

        test_route "une/route" do
        
        end
        
    Vous pouvez trouver dans ce document la [liste de toutes les méthodes de test](#listemethodesdetest).
* une description par défaut existe pour toutes les méthodes de test mais on peut définir une description plus appropriée à l'aide de `description` :

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
      html.has_titre("Bienvenue !", niveau: 1)
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

Noter que puisque cette méthode de test hérite des méthodes de test de la route, on peut aussi bien tester la validité du formulaire en lui-même — en tant qu'objet DOM — que son efficacité lorsqu'on le soumet avec des données valides ou non. 

Mais noter qu'il peut s'agir de deux routes différentes. Par exemple, pour un `RestSite` classique, on utilise la route `user/signin` pour atteindre le formulaire d'identification tandis qu'on utilise la route `user/login` pour identifier l'user en soumettant ce questionnaire. Donc on aura :

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

## Méthodes de cas du module `ModuleRouteMethods`

* [respond & dérivées](#methoderesponds)
* [has_tag & dérivées](#methodtesthastag)
* [has_title & dérivées](#methodehastitle)
* [`has_message` & dérivées](#casemethodhasmessage)


<a name='methoderesponds'></a>

#### `responds`

Retourne très si la commande renvoie une page valide (code 200)

        responds

Négatif : `not_responds`

Sans évaluation : `responds?`

        Formes
    ---------------------------------------------------------------------
      Negative        simple évaluation     plurielle
      
      not_responds    responds?              ---


<a name='methodehastitle'></a>

#### `has_title`

Produit un succès si la page contient le titre spécifié, au niveau spécifié (if any)

@syntaxe

        has_title <titre>[, <niveau>][, <options>]

        Formes
    ---------------------------------------------------------------------
      Negative        simple évaluation     plurielle
      
      has_not_title   has_title?            has_titles

<a name='casemethodhasmessage'></a>

## `has_message`

    has_message <message>[, <options>]
    
        Formes
    ---------------------------------------------------------------------
      Negative          simple évaluation     plurielle
      
      has_not_message   has_message?          has_messages


<a name='methodtesthastag'></a>

#### `has_tag`

Produit un succès si la page contient le tag spécifié.

@syntaxe

        r.has_tag <tag>[, <options>]
        
        ou
        
        r.has_tag( [<tag>, <tag>, <tag>] ) # test une liste de balises


        Formes
    ---------------------------------------------------------------------
      Negative        simple évaluation     plurielle
      
      has_not_tag     has_tag?              has_tags


@exemples

    test_route "ma/route" do
      html.has_tag "div#mondiv.soncss"
      html.has_tag "div", {id:"mondiv", class:'soncss'}
      html.has_not_tag "span", {text: /Bienvenue !/}
      html.has_tags(['div#premier', 'div#deuxieme', 'div#troisieme'])
    end




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

### Méthodes-case `methode`, `not_methode`, `methode?` et `methodeS`

La plupart des méthodes de test possèdent QUATRE états différents qui correspondent à quatre actions et retours différents :

La méthode DROITE ou "test-case"
: C'est la méthode qui produit une évaluation, donc un succès ou une failure.
: Par exemple : `has_titre`

La méthode INVERSE ou "not-méthode"
: La méthode inverse fait le contraire de la méthode droite. Un "not" est ajouté à son nom, soit au début, soit au milieu.
: Par exemple : `has_not_titre`

La méthode "interrogation"
: La méthode "interrogation" ne produit pas d'évaluation (ie pas de message de failure ou de success), elle retourne simplement `false` ou `true` en fonction du résultat.
: Par exemple : `has_titre?`

Les méthodes "plurielles"
: La méthode "pluriel" répète pour chaque élément qu'elle reçoit un test-case de son type.
: Par exemple, la méthode `has_tags` attend une liste de liste d'attributs pour `has_tag`. La méthode `has_not_tags` attend une liste d'attributs qui ne doivent pas exister dans la page.

Note : Noter que chaque élément de cette liste peut être soit une liste d'argument soit un argument seul :

    has_tags ["premier#tag", "div#interieur"]
    
    has_tags [
      ["span", {class: "sacss", count:5}],
      "div#seul"
    ]
    
    # Avec un dernier argument options
    has_tags ["span#unnom", "span#unautre"], {class:'unspan'}
    # Le dernier argument sera utilisé pour tous les appels. Donc cette
    # méthodes produira&nbsp;:
    
        has_tag("span#unnom", {class:'unspan'})
        has_tag("span#unautre", {class:'unspan'})
    

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

        test_form "la/route", <data> do

          <case-methode>

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

    Formes
    Negative        simple évaluation     plurielle
      
    not_exist       exist?                  ---


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
