# Aide

* [Création d'un fichier d'aide](#creationfichieraide)
  * [Titre du fichier d'aide](#titreformated)
  * [Ajout aux tables des matières](#ajoutealatabledesmatiers)

Toute l'aide se trouve dans le dossier `./objet/unan/aide`.

Pour les liens helper, cf. Vues > Methodes_LIENS.md.

<a name='creationfichieraide'></a>

## Création d'un fichier d'aide

Un nouveau fichier d'aide doit être créé dans le dossier `./objet/unan/aide`.

<a name='titreformated'></a>

### Titre du fichier d'aide

Pour indiquer le titre du fichier d'aide, utiliser :

    <%= Unan::Aide::titre("Sous titre") %>

Cela affiche le titre "Aide", le sous-titre fourni et un lien pour rejoindre la table des matières.

<a name='ajoutealatabledesmatiers'></a>

### Ajout aux tables des matières

Le nouveau fichier d'aide doit être ajouté à la table des matières générale dans le fichier :

    ./objet/unan/aide/home.erb

Il doit être aussi certainement ajouté à la table des matières du fichier “home.erb” de son dossier.
