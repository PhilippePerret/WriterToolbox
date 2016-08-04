# Anciennes analyses

* [Introduction](#introduction)
* [Dossier des analyses](#dossierdesanalyses)
* [Nom du dossier de l'analyse](#nomdudossierdanalyse)
* [Constitution du dossier d'analyse](#constitutiondudossier)
* * [Fichier table des matières `tdm.yaml`](#fichiertabledesmatières)

<a name='introduction'></a>

## Introduction


Ce que j'appelle “anciennes analyses”, en fait, peut comprendre des analyses beaucoup plus récentes. Elles sont appelée comme ça car elles reprennent les anciens fichiers utilisés depuis Scenariopole.


<a name='dossierdesanalyses'></a>

## Dossier des analyses

Le dossier des analyses de ce type se trouve dans :

    ./data/analyse/film_MYE

<a name='nomdudossierdanalyse'></a>

## Nom du dossier de l'analyse

Le dossier de l'analyse générale doit correspondre au `film_id` du film. ATTENTION : Pour rappel, le “film_id” du film n'a rien à voir avec l'ID {Fixnum} du film. Le `film_id` est une propriété `String` des films du filmodico.

<a name='constitutiondudossier'></a>

## Constitution du dossier d'analyse

À la base, un dossier d'ancienne analyse est constitué de :

    introduction.md     Fichier markdown servant d'introduction
    tdm.yaml            Fichier YAML contenant la table des matières de
                        l'analyse. Cf. Table des matières plus bas
    (dossiers)          Des dossiers contenant les articles
    (fichiers.yaml)     Des fichiers YAML contenant d'autres données
                        récoltées au cours de analyses.

Pour une vision d'ensemble et voir comment formater ces fichiers et dossiers, on peut jeter un coup d'œil à `./data/analyse/film_MYE/AIArtificialIntelligence2001` qui contient l'ensemble des éléments possibles.

* [Affichage des anciennes analyses](#affichagedecesnalayses)
<a name='affichagedecesnalayses'></a>

## Affichage des anciennes analyses

L'affichage de ces données se fait à présent par le même module que les analyses TM, c'est à l'intérieur de la vue que le traitement est différent.

    ./objet/analyse/show.erb

C'est à pr
Noter que cette vue ERB utilise le module `lib/module/archives` des analyses pour s'afficher.

<a name='fichiertabledesmatières'></a>

## Fichier table des matières `tdm.yaml`

Ce fichier ressemble à :


    -
      path:   fiche/themes.md
      titre:  À propos des thèmes du film
    -
      path:   fiche/personnages.md
      titre:  Quelques notes sur les personnages
    -
      path:   evc/scenier.evc
      titre:  Scénier du film
      ancre:  evcscenierevcscenierdufilm
      introduction: |
        Scénier complet du film qui pourra servir de base de référence à
        toute analyse complémentaire. On peut trouver le début du
        MOT[38|Dénouement] dont nous parlons au début de ce document (à `1:34:00`) en
        <a href="analyse/128/show#scenier-denouement">cliquant ici</a>.


On peut noter la dernière donnée qui définit tous les attributs possibles :

    path        Le path du fichier
    titre       Le titre qui sera affiché au-dessus du fichier
    ancre       Pour définir une ancre explicitement.
                Noter que tous les titres définissent une ancre, dans la
                propriété :anchor, mais qu'ici on peut avoir une ancre plus
                parlante.
    description
                Une description qui sera affichée au-dessus du contenu du
                fichier, par exemple pour l'introduire.
