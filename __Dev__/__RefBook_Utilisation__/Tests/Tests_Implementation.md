# Implémentation

* [Problèmes à résoudre](#problemearesoudre)
* [Méthodes de tests des Files](#fichierdefinissantlesmethodesdetestdefile)
* [Créer une nouvelle méthode de test](#creerunnouveautest)
  * [Définir le nouveau test (MÉTHODE-TEST)](#definitiondunouveautest)
  * [Définir l'OBJET-CASE](#definirlobjetcase)
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
