# TODO
* [Isolation de la fabrication LaTex d'un livre](#isolationdelafabricationlatexlivre)


<a name='isolationdelafabricationlatexlivre'></a>

## Isolation de la fabrication LaTex d'un livre

Cette fonctionnalité doit permettre de partir d'un ensemble de source en `markdown` et d'en tirer un livre.

Noter qu'il ne s'agit pas de la procédure utilisée pour la collection Narration mais celle utilisée pour les manuels, à commencer par le manuel de l'auteur du programme UN AN UN SCRIPT.

### Fonctionnement :

#### Côté module (gem)

On a un ensemble de choses prédéfinies, comme les packages de base, certaines commandes, etc.

On a toutes les libraires ruby qui permettent de traiter le livre.

#### Côté livre à construire

On a un ensemble de sources `markdown` (pseudo-markdown en fait puisqu'il y a du code LaTex dedans et du code ERB).

Dans ces sources markdown (dossier `sources_md`), on trouve le fichier table des matières `tdm.yaml` qui va déterminer dans quel ordre traiter les fichiers.

On a un ensemble de fichiers latex (.tex) qui déterminent certaines choses comme :

* les commandes propres
* la page de couverture (`cover.tex`)

On a un fichier de configuration qui détermine certaines choses, à commencer par le titre à donner au fichier PDF final (noter que ce nom ne sera jamais utilisé en "interne" — en interne on utilise toujours l'affixe 'main' pour faire référence aux fichiers principaux).

### Question

Faut-il traiter les bibliographies ? Si oui, comment ?
