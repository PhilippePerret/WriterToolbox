# Aide pour la collection Narration

Voir aussi le fichier aide.erb qui contient pour le moment d'autres informations.

* [Images](#utilisationduneimage)
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
