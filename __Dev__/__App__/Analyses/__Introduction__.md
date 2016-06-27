# Introduction aux analyses

* [Introduction](#introductionauxanalyses)
* [Les analyses TM (TextMate)](#lesanalysestm)
* [Les analyses MD-YAML](#lesanalysemdyamla)

<a name='introductionauxanalyses'></a>

## Introduction

Il existe deux **grands types d'analyse** :

* Les **analyses TM**, ou “analyse TextMate”, qui sont les plus récentes et se font à l'aide de l'application `Film_TM` qui gère des fichiers de relève.

* Les **analyses MD-YAML**, qui fonctionnent à l'aide de données enregistrées dans des fichiers YAML et des fichier MD.

<a name='lesanalysestm'></a>

## Les analyses TM (TextMate)

<a name='lesanalysemdyamla'></a>

Les films analysés se trouvent dans :

    ./data/analyse/film_tm/

Les analyses TM s'affichent de façon particulière puisqu'elles masquent tous les éléments inutiles de l'interface pour prendre toute la largeur de la page. C'est dans le fichier `./objet/analyse/show.rb`, dans la méthode `output_as_analyse_tm` qu'est implémenté le masquage de tous les éléments de l'interface.


## Les analyses MD-YAML

Les films analysés sont définis dans le dossier :

    ./data/analyse/film_MYE/
