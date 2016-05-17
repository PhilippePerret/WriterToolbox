# Tests

* [Introduction](#introductionteststest)
* [Lancer des tests](#lanceruntest)
  * [Lancer une suite de tests (`test dossier online`)](#lancerunesuitedetests)
  * [Lancer une configuration de tests (`run test`)](#lancerdestestsspecifique)
* [Hiérarchie des éléments](#hierarchiedeselements)
* [Implémentation du test](#implementation_du_test)
* [Débuggage du test](#debugging)

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

<a name='lanceruntest'></a>

## Lancer des tests

<a name='lancerunesuitedetests'></a>

### Lancer une suite de tests (`test dossier online`)


Pour lancer des tests, on utilise la console. La commande de base est&nbsp;:

    test[ <options>] <dossier>[ <lieu>]
    
où&nbsp;:

    options
    -------
        Les options peuvent être spécifiées de façon habituelles, soient
        avec "-" soit avec "--" :
          --debug           Mode débuggage. Envoie des messages au débug
          -v, --verbose     Mode bavard, affiche le détail des tests
          -q, --quiet       Mode silencieux. Seul le nom des test-méthodes
                            est indiqué.
                            
    dossier
    -------
        C'est un sous-dossier du dossier principal `./test`. N'importe
        quel sous-dossier peut être spécifié ici.
    
    lieu
    ----
        Ajouter simplement "online" ou "offline"
        Pour déterminer si les tests doivent se faire en online ou en
        offline.
        Si lieu n'est pas déterminé, les tests sont faits en offline, donc
        sur le site local.

<a name='lancerdestestsspecifique'></a>

### Lancer une configuration de tests (`run test`)

On peut lancer une configuration précise de test avec la commande&nbsp;:

    run test
    ou
    test run

Cf. le fichier "Fichier_run.md" pour le détail de l'opération.

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

Cf. le dossier Test_implementation.md

<a name='debugging'></a>

## Débuggage du test

On peut obtenir des informations de débugging tout au long du test en utilisant les méthodes `start_debug` — qui ouvre le débugging et la méthode `stop_debug` qui ferme le débugging.

Noter que ces deux méthodes peuvent s'utiliser aussi bien à la base des fichiers de test :

~~~ruby

  # In ./test/mon_test_spec.rb
  ...
  start_debug
  
  test_form ... do
    ...
  end
  
  ...
  
  stop_debug
  
  ...
  
~~~

… aussi bien qu'à l'intérieur même d'une méthode de test :

~~~ruby

test_route "ma/route" do
  html.has_tag("div#tag")
  start_debug
  html.has_message("Je commence le débuggage !")
  stop_debug
  html.has_message("J'ai arrêté de débugguer")
end

~~~

Les messages sont inscrits dans le débug normalement des sites, c'est-à-dire sous la page.