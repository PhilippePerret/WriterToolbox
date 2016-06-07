# Aide

* [Route pour appeler un fichier d'aide](#lienpourappelerfichieraide)
* [Création d'un nouveau fichier d'aide](#creationdunnouveaufichierdaide)
* [Ajout un fichier d'aide à la table des matières](#ajoutfichieraidetdm)

La section aide se trouve dans `./objet/aide`.

<a name='lienpourappelerfichieraide'></a>

## Route pour appeler un fichier d'aide

@usage

    aide/<identifiant fichier>/show

Pour trouver facilement l'identifiant, il suffit de trouver le fichier dans le dossier `./objet/aide/lib/data/texte` et de prendre la partie de son nom au début avant le '-'.

<a name='creationdunnouveaufichierdaide'></a>

## Création d'un nouveau fichier d'aide

* Trouver un identifiant libre pour le fichier, en consultant les ID utilisés dans le dossier `./objet/aide/lib/data/texte`.

  Note : Les identifiants correspondent à la première partie du nom du fichier,

* Créer le fichier dans ce dossier. Son nom doit commencer impérativement par son identifiant, suivi d'un tiret, mais ensuite on peut mettre ce qu'on veut. L'extension peut être `md` (fichier markdown), `erb` (fichier ERB), `htm` ou `html` (fichier HTML) ou tout autre format mais qui sera inséré "as-is",

* Rédiger le fichier dans le format voulu,
* Ajouter le fichier à la table des matières (in `./objet/aide/lib/data/tdm.rb`),
* Peut-être faire une nouvelle update (console, taper `update` puis tabulation — mettre l'annonce à 1 pour envoyer à tout le monde si c'est une aide importante et régler l'importance).

<a name='ajoutfichieraidetdm'></a>

## Ajout un fichier d'aide à la table des matières

Pour ajouter un fichier d'aide à la table des matières, il suffit de l'ajouter dans la donnée `DATA_TDM` du fichier `./objet/aide/lib/data/tdm.rb`.

Mettre en clé la route du fichier (par exemple `aide/12/show`) et en `:hname` le titre humain qui sera affiché dans la table des matières. Il vaut mieux utiliser le même titre que dans le fichier.
