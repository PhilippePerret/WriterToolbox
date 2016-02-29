# Anciennes analyses

* [Introduction](#introduction)
* [Dossier des analyses](#dossierdesanalyses)
* [Nom du dossier de l'analyse](#nomdudossierdanalyse)
* [Constitution du dossier d'analyse](#constitutiondudossier)

<a name='introduction'></a>

## Introduction


Ce que j'appelle “anciennes analyses”, en fait, peut comprendre des analyses beaucoup plus récentes. Elles sont appelée comme ça car elles reprennent les anciens fichiers utilisés depuis Scenariopole.


<a name='dossierdesanalyses'></a>

## Dossier des analyses

Le dossier des analyses de ce type se trouve dans :

    ./data/analyse/data_per_film

<a name='nomdudossierdanalyse'></a>

## Nom du dossier de l'analyse

Le dossier de l'analyse générale doit correspondre au `film_id` du film. ATTENTION : Pour rappel, le “film_id” du film n'a rien à voir avec l'ID {Fixnum} du film. Le `film_id` est une propriété `String` des films du filmodico.

<a name='constitutiondudossier'></a>

## Constitution du dossier d'analyse

À la base, un dossier d'ancienne analyse est constitué de :

    introduction.md     Fichier markdown servant d'introduction
    tdm.yaml            Fichier YAML contenant la table des matières de
                        l'analyse
    (dossiers)          Des dossiers contenant les articles
    (fichiers.yaml)     Des fichiers YAML contenant d'autres données
                        récoltées au cours de analyses.

Pour une vision d'ensemble et voir comment formater ces fichiers et dossiers, on peut jeter un coup d'œil à `./data/analyse/data_per_film/AIArtificialIntelligence2001` qui contient l'ensemble des éléments possibles.

* [Affichage des anciennes analyses](#affichagedecesnalayses)
<a name='affichagedecesnalayses'></a>

## Affichage des anciennes analyses

L'affichage de ces données se fait par le module :

    ./objet/analyse/show_archive.erb

Noter que cette vue ERB utilise le module `lib/module/archives` des analyses pour s'afficher.
