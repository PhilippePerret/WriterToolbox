# Les Vues

* [Le Gabarit](#le_gabarit)
* [Insérer une vue dans une autre vue](#inserervuedansvue)


<a name='le_gabarit'></a>

## Le Gabarit

Le gabarit est composé de fichiers qui sont répartis dans deux dossiers :

Un dossier "profond" avec des fichiers qui ne devraient pas être modifiés

    ./view/deep/deeper/gabarit/

Un dossier accessible contenant les fichiers à définir proprement à l'application développée :

    ./view/gabarit/

<a name='inserervuedansvue'></a>

## Insérer une vue dans une autre vue

Pour insérer une vue dans une autre vue, on peut utiliser le code

    <%= page.view('path/from/dossier/objet/vue_sans_erb'[, bindee])
