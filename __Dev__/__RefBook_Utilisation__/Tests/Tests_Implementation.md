# Implémentation

* [Méthodes de tests des Files](#fichierdefinissantlesmethodesdetestdefile)
* [Créer une nouvelle méthode de test](#creerunnouveautest)
  * [Définir le nouveau test (MÉTHODE-TEST)](#definitiondunouveautest)
  * [Définir l'OBJET-CASE](#definirlobjetcase)


<a name='fichierdefinissantlesmethodesdetestdefile'></a>

## Méthodes de tests des Files
Ce que j'appelle les "méthodes de tests des Files", ce sont les méthodes principales qu'on peut trouver dans les fichiers `spec`. Par exemple, la méthode `test_route` est une méthode de tests de files :

        test_route "ma/route" do |r|
          r.responds
          r.has_title("Bienvenue !", 1)
          r.has_tag("section#content")
        end

Ces méthodes se définissent dans le fichier :


        ./lib/deep/deeper/module/test/TestFile/test_methods.rb

S'inspirer des méthodes de ce fichier pour composer les autres méthodes


<a name='creerunnouveautest'></a>

## Créer une nouvelle méthode de test

<a name='definitiondunouveautest'></a>

### Définir le nouveau test (MÉTHODE-TEST)


IL faut créer les nouvelles méthodes de test dans :

        ./lib/deep/deeper/module/test/TestFile/test_methods.rb

Lui trouver un nom et le nombre de paramètres adéquat.

Par exemple, pour teste un formulaire, j'ai utilisé :

        test_form

Ensuite, il faut définir le nombre de paramètres. Pour `test_route`, le seul paramètre nécessaire était la route, pour `test_form`, il faut la route et les données à envoyer :

        test_form route, data[, options_ou_libelle_ou_line]

Dans la feuille de test, la méthode va donc ressembler à :

        test_form route, data do |f|

          f.<methode de cas>

        end

<a name='definirlobjetcase'></a>

### Définir l'OBJET-CASE

Ensuite, on doit définir l'OBJET-CASE, une classe qui va permettre de gérer les "méthodes de cas". Cette classe produira le `f` utilisé ci-dessus.

Pour notre test `test_form`, cet OBJET-CASE est un formulaire, on va faire la classe  `SiteHtml::TestSuite::Form` :

> Note : tous les chemins ci-dessous sont entendus à partir de `./lib/deep/deeper/module/test`.

* On crée un dossier pour la classe dans `_/test/case_objet`
* On crée un fichier d'instance `instance.rb` dans ce dossier. Ici, la classe sera :

    ~~~ruby
        class SiteHtml
        class TestSuite
        class Form

          ...

    ~~~

* On crée l'instanciation de l'objet-case. Ici, puisque nous avons 2 arguments transmis à `test_form`, ces deux arguments seront envoyés à l'instanciation. On charge plusieurs modules de méthodes pour cet objet-case, qui seront utiles plus tard :

    ~~~ruby
        ...
        class Form

          # Normalement, doit être chargé par tout objet-case
          include ModuleObjetCaseMethods

          # Quand il y a des routes/pages à gérer
          include ModuleRouteMethods

          # Inutile de définir `raw_route` ici car c'est déjà
          # une variable définie dans le module ModuleRouteMethods
          # attr_reader :raw_route

          attr_reader :data_form

          def initialize route, data = nil
            @raw_route  = route
            @data_form  = data

    ~~~

    > Note : `raw_route` est un nom obligé car les méthodes du module
    `ModuleRouteMethods` en ont besoin.

* On crée les méthodes de case de cet objet-case. On les implémente dans un fichier `_/test/case_objets/form/case_methods.rb`.

    Par exemple, pour notre objet-case `Form`, on va avoir une méthode de cas pour s'assurer d'abord que notre formulaire existe et une autre pour le remplir :

        ~~~ruby

          ...
          class Form

            def exist
              ...
            end

            def fill args = nil
              ...
            end
        ~~~

* On implémente la méthode-test dans le fichier `_/test/TestFile/test_methods.rb` en se servant de notre objet-case. Ces méthodes ont toujours la même forme générale :

    * Elles créent l'objet-case (ici le formulaire)
    * Elles créent un `ATest` pour gérer ce test
    * Elles évaluent ce test en envoyant le bloc de code

    ~~~ruby

        # Dans test/TestFile/test_methods.rb

        # Note : Toutes 
        def test_form la_route, les_data, options = nil

          # On crée l'objet-case propre à ce test
          f = SiteHtml::TestSuite::Form::new(la_route, les_data)

          # On crée une instance test qui permettra de gérer tous les
          # succès et toutes les failures.
          # Le 2e argument sera le nom par défaut à donner au test
          # dans le cas où `options` ne le définirait pas.
          atest = ATest::new(self, "FORM #{f.url}", options)

          # On évalue le bloc de code de test_form
          atest.evaluate{ yield f }

        end

    ~~~
