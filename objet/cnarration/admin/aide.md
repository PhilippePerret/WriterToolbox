# Aide pour la collection Narration

* [Les Pages narration](#lespagesnarration)
  * [Création d'une nouvelle page](#creationdunenouvellepage)
* [Les Textes](#lestextes)
* [Images](#utilisationduneimage)

<a name='lespagesnarration'></a>

## Les Pages narration

<a name='creationdunenouvellepage'></a>

## Création d'une nouvelle page

Pour créer une nouvelle page, on peut utiliser plusieurs moyens :

* par l'éditeur de données de page
* par la console

### Par l'édition de données de page

* rejoindre l'éditeur de données en utilisant la commande console `new page narration`
* choisir le livre,
* choisir le titre,
* choisir l'emplacement du fichier dans le dossier du livre. Noter qu'il n'a pas besoin d'être en relation avec son emplacement dans la table des matières.
* cocher la case “créer le fichier” s'il n'existe pas encore et qu'on veut le créer,
* mettre un descriptif si nécessaire
* cliquer le bouton “Créer la page” (ou similaire)

On peut immédiatement éditer la table des matières du livre en cliquant le bouton `edit tdm` en regard du titre du livre, pour placer la page.

### Par la console

Rejoindre la console et taper la commande :

    create|creer page narration in[ID_LIVRE] handler[LE_PATH_RELATIF] titre[LE TITRE DE LA PAGE]

    Optionnellement on peut ajouter :

        description[DESCRIPTION DE LA PAGE]
        after[ID_PAGE_OU_TITRE]





<a name='lestextes'></a>

## Les Textes

[Aide Kramdown](http://kramdown.gettalong.org)



<a name='utilisationduneimage'></a>

## Images

    IMAGE[path/relatif|titre optionnel]

Le `path relatif` est traité de cette façon : on s'attend à trouver l'image dans un dossier du dossier `img` du dossier du livre au même niveau que le fichier lui même.

Par exemple, si le fichier est :

    .../concepts/dimensions_hsp/mon_fichier.md

… alors si une image dans le fichier `mon_fichier.md` est spécifié par :

    IMAGE[mon_image]

… on la recherchera dans :

    .../concepts/img/dimensions_hsp/mon_image.png

### Autres path

On peut spécifier un autre path dans le dossier images du livre en partant du dossier `img`.

On peut également spécifier un autre path en partant de la racine du site lui-même (mais attention, dans ce cas, les dossiers ne seront plus portables ailleurs).

Donc, par ordre de précédence, on trouve :

    1. Recherche avec le même path relatif dans img
    2. Recherche avec le path relatif fourni dans le dossier img
    3. Recherche avec le path relatif dans le site.


### Autres formats

Si l'image doit avoir un autre format que `png` il suffit de l'indiquer dans le nom.

    IMAGE[mon_image_jpeg.jpg]

### Titre alt

On peut préciser le titre alternatif par :

    IMAGE[image|Mon titre alternatif]
