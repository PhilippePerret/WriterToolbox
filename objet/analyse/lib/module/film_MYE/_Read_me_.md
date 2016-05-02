Ce dossier 'module/archives' a été initié pour traiter les anciennes analyses de film qui viennent de Scenariopole. Noter qu'on pourra tout à fait produire de nouvelles analyses selon ce principe, car elles sont pratiques dans le traitement de nombreux types de fichiers.

Ces analyses s'appellent des “Analyse M.Y.E.”  ou “Analyses MD-YAML-EVC” du nom des trois types de fichiers qu'elles utilisent, Markdown (MD), YAML et EVC (mon format pour les évènemencier). Noter qu'on utilise aussi le format EVC

* [Affichage (ordre) des données](#affichagedesdonnees)
* [Affichage des données MD](#affichagedesdatamd)
* [Affichage des fichiers YAML](#affichagedesyaml)
* [Affichage des évènemenciers](#affichagedesevc)


<a name='affichagedesdonnees'></a>

## Affichage (ordre) des données

Afficher les données dans l'ordre où le programme listerait les fichiers donnerait une affichage pas très pertinent. Plutôt que de faire ça, on classe les fichiers.

    introduction.md

      Si c'est fichier existe à la racine du dossier, il est chargé
      en tout premier.

    tdm.yaml

      Si ce fichier existe à la racine du dossier du film, il définit
      l'ordre d'affichage des fichiers. Dans le cas contraire, c'est
      l'ordre "naturel" qui est choisi.


<a name='affichagedesdatamd'></a>

## Affichage des données MD

C'est un traitement "normal" qui est appliqué, par `SuperFile`, comme tout fichier Markdown sur le site.

<a name='affichagedesyaml'></a>

## Affichage des fichiers YAML

Le fichier est traité par le module :

    ./objet/analyse/lib/module/film_MYE/superfile/yaml_traitements.rb

<a name='affichagedesevc'></a>

## Affichage des évènemenciers
