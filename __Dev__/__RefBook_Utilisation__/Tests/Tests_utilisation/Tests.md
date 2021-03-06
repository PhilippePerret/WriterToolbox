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

<a name='implementation_du_test'></a>

## Implémentation du test

Cf. le dossier Test_implementation.md

<a name='debugging'></a>

## Débuggage du test

> Voir aussi le fichier `Debug_methods.md`

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
