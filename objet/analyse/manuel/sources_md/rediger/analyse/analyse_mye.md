
* [Présentation des analyses MYE](manuel/rediger?in=analyse&manp=analyse/analyse_mye#presentationdesanalysesmye)
* [Réalisation d'un fichier de table des matières](manuel/rediger?in=analyse&manp=analyse/analyse_mye#realisationfichiertdm)
* [Fichier d'introduction de l'analyse](manuel/rediger?in=analyse&manp=analyse/analyse_mye#fichierintroductionauto)

<a name='presentationdesanalysesmye'></a>

## Présentation des analyses MYE


Les “Analyses MYE” sont des analyses fonctionnent sur la base de trois types de fichier :

* **markdown**. Pour écrire toute sorte d'articles,
* **yaml**. Pour réaliser toute sorte de listings (procédés, notes, etc.),
* **evc**. Format propre pour les évènemenciers.


<a name="realisationfichiertdm"></a>

#### Réalisation d'un fichier de table des matières

Pour réaliser un fichier de table des matières, il faut créer le fichier&nbsp;:

    tdm.yaml

… à la racine du dossier de l'analyse.

Dans ce fichier, on appelle chaque fichier à l'aide d'une définition&nbsp;:

    -
      path:     path/to/file.ext
      titre:    Titre à donner dans le fichier de l'analyse

Le `path` se calcule depuis la racine du dossier de l'analyse du film concerné.

D'autres éléments peuvent être définis comme&nbsp;:

    -
      ...
      
      incipit:      Un texte qui sera ajouté en haut du fichier, en 
                    italic et en plus petit.
      conclusion:   Un texte qui sera ajouté à la fin du fichier.

> Note&nbsp;: `incipit` et `conclusion` sont utiles par exemple pour les fichiers YAML et EVC qui ne peuvent pas contenir de texte hors de leurs rubriques normales.


<a name='fichierintroductionauto'></a>

## Fichier d'introduction de l'analyse

S'il existe un fichier à la racine du dossier d'analyse qui s'appelle&nbsp;:

    introduction.tm
    
… alors il est automatiquement chargé en début d'analyse.