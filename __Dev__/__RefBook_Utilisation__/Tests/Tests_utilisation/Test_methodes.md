# Les `test-méthodes`

* [Définition](#definitiondesmethodesdetests)
* [Liste des méthodes de test](#listemethodesdetest)
  * [Test-méthode URL `test_route`](#methodetesttestroute)
  * [Test-méthode FORM `test_form`](#methodedetesttestform)
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
