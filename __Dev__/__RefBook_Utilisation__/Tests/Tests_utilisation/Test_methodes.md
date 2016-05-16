# Les `test-méthodes`

* [Définition](#definitiondesmethodesdetests)
* [Liste des méthodes de test](#listemethodesdetest)
  * [Test-méthode URL `test_route`](#methodetesttestroute)
  * [Test-méthode FORM `test_form`](#methodedetesttestform)
  * [Test-méthode DATABASE `test_base`](#testmethodesdatabase)
    * [Case-objets de la test-méthode `test_base`](#casesobjetsdetestbase)
      * [Case-objet `row`](#caseobjetrowdetestbase)
* [Rendre un test-méthode NON FATALE](#rendretestmethodenonfatale)
* [Options de dernier argument de méthode-test](#optionsdefinmethodestest)


<a name='definitiondesmethodesdetests'></a>

## Définition

Les “méthodes de test” sont les objets supérieurs des feuilles de test. Elles correspondent aux `describe` de RSpec, mais fonctionnent déjà comme un ensemble de `it`.

<a name='listemethodesdetest'></a>

## Liste des méthodes de test


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

* [Case-objets de la test-méthode `test_route`](#caseobjetsdelatestmethoderoute)
<a name='caseobjetsdelatestmethoderoute'></a>

#### Case-objets de la test-méthode `test_route`

* html

`html` est une instance `SiteHtml::TestSuite::HTML` dont la propriété `page` est un `Nokogiri::Document` permettant de faire tous les tests sur le code. Par exemple&nbsp;:

~~~ruby

  html.has_tag("div#un_div_present")
  html.has_message("Mon message", {strict: true})
  
~~~

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

<a name='testmethodesdatabase'></a>

### Test-méthodes des bases de données (`test_base`)

Permet de tester les bases de données. Exemple&nbsp;:

~~~ruby

  test_base "path/to/base.table" do
    has_row({id: 12, phil: "Phil", activity: 13})
  end
  
  test_base "users.users"{ row(2).exists }
  
~~~

@syntaxe

~~~ruby

  test_base "<base sans .db>.<table>" do
    <case-méthode>
    <case-méthode>
    ...
  end
~~~

<a name='casesobjetsdetestbase'></a>

#### Case-objets de la test-méthode `test_base`


<a name='caseobjetrowdetestbase'></a>

##### Case-objet `row`

`row` est un objet de classe `SiteHtml::TestSuite::DBase::Row` qui contient des méthodes de case et des méthodes de gestion&nbsp;:

~~~ruby

row(...).exists
row(...).delete
row(...).insert(...data...)
row(...).has(...data...)

~~~

Noter que ces méthodes fonctionnent aussi bien online qu'offline donc qu'il faut être particulièrement prudent, même si des backups sont produits.

**Données de la rangée**

On peut obtenir les données de la rangée par&nbsp;:

~~~ruby

  thdata = row(...).data
  # Noter que c'est un THash

~~~

La valeur retournée est un `THash`, pas un `Hash` donc on peut utiliser sur lui toutes les méthodes normales des `Hash` mais en plus les case-méthodes propres, à commencer par `has`, `has_not` etc. pour vérifier qu'il y a bien ces données.

---------------------------------------------------------------------

<a name='rendretestmethodenonfatale'></a>

## Rendre un test-méthode NON FATALE

Par défaut, lorsqu'un cas (une case-méthode) d'un test-méthode échoue, cela produit l'arrêt de ce test-méthode. Mais dans certain cas, par exemple le test d'existence d'éléments multiples dans une page, on peut vouloir que le test se poursuive tout de même.

Dans ce cas, on passe le test-méthode en mode `NON FATAL` à l'aide de la méthode&nbsp;:

~~~ruby

  non_fatal
  
  ou
  
  not_fatal
  
~~~

Par exemple&nbsp;:

~~~ruby

test_route "ma/route" do
  non_fatal
  has_tag("div#letage")
  has_tag("nimporte#quoi") # inexistant, mais n'interrompra pas le test
  has_tag("span#pourvoir")
  ...
  has_tag("toujours#played") # quoi qu'il advienne, ce case-test sera toujours
                             # joué
end

---------------------------------------------------------------------

<a name='optionsdefinmethodestest'></a>

## Options de dernier agument de méthode-test

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
