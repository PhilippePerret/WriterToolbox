# Tests

* [Introduction](#introductionteststest)
* [Hiérarchie des éléments](#hierarchiedeselements)
* [Implémentation du test](#implementation_du_test)

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
