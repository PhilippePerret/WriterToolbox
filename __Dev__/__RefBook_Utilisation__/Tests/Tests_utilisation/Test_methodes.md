# Les `test-méthodes`

* [Définition](#definitiondesmethodesdetests)
* [Liste des méthodes de test](#listemethodesdetest)
  * [Méthode de test `test_route`](#methodetesttestroute)
  * [Méthode de test `test_form`](#methodedetesttestform)
* [Options de dernier agument de méthode-test](#optionsdefinmethodestest)


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
