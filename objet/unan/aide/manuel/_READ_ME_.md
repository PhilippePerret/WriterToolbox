# Manuel de l'auteur

* [Reconstruction du manuel](#reconstructiondumanuel)
  * [Ordre d'inclusion des fichiers](#ordredesfichiers)
* [Titres des chapitres, sections etc.](#titredessections)
  * [Spécifier un ID/Label propre pour un titre](#specifierunlabelidpropre)
  * [Les labels de titre automatiques](#labelautomatiques)
* [Références croisées](#referenceadesparties)
  * [Définition des liens en entête](#definitiondesliensenentete)
  * [Définition des liens courants](#definitiondeslienscourants)
  * [Ajouter des attributs propres](#utiliserattributsproprespourlien)

<a name='reconstructiondumanuel'></a>

## Reconstruction du manuel

Pour le moment, il faut lancer la construction du manuel à l'aide du script se trouvant à l'adresse :

        ./__Dev__/_Usefull_/build_manuel_unan_user.rb

Utiliser plutôt TextMate.


<a name='ordredesfichiers'></a>

### Ordre d'inclusion des fichiers

L'ordre d'inclusion des fichiers est défini dans un fichier table-des-matières situé à la racine du dossier principal (au même niveau que ce fichier d'aide).

Il peut avoir indifféremment les noms suivants :

        tdm.yaml
        TDM.yaml
        _tdm_.yaml
        _TDM_.yaml

C'est une simple liste définition l'ordre, avec le **path relatif** des affixes des fichiers à partir de `./sources_md/` (qui n'est donc pas à indiquer) :

        - path/to/fichier1
        - path/to/fichiers2
        etc.

Noter que, bien sûr, seuls des fichiers `Markdown` doivent être consignés dans cette table des matières.

<a name='titredessections'></a>

## Titres des chapitres, sections etc.

Dans l'idéal, il faudrait que **aucun titre ne soit identique** car lorsque `kramdown` procède à la transformation en LaTex, il applique des `label` en se servant exactement du titre (sans du tout tenir compte qu'il ait déjà été utilisé).

<a name='specifierunlabelidpropre'></a>

### Spécifier un ID/Label propre pour un titre

Il suffit d'écrire le titre ainsi :

        ### Mon titre     {#id-propre-pour-ce-titre}

ATTENTION : Ne pas utiliser de traits plats, ils seraient transformés en `\_` par kramdown.

<a name='labelautomatiques'></a>

### Les labels de titre automatiques

Entendu que Kramdown applique des labels en fonction du titre, on peut faire référence à une partie en composant le label fabriqué par Kramdown selon ces principes (sauf si l'on a spécifié un ID/Label propre](#specifierunlabelidpropre)) :

* toutes les lettres sont passées en minuscules,
* Les apostrophes sont supprimés
* toutes les letres autres que a-z et 0-9 sont supprimées,
* tous les mots sont reliés par "-"

Donc, par exemple :

        Un titre pour VOIR  => \label{un-titre-pour-voir}
        C'est l'été         => \label{cest-lt}

<a name='referenceadesparties'></a>

## Références croisées

On peut utiliser le système normale de Markdown :

        [texte du lien](adresse du lien)

Pour le moment, je ne sais pas comment placer une ancre n'importe où dans le texte, donc ces références doivent pointer vers des titres seulement. Par exemple :

        <!-- Quelque part dans le texte markdown -->

        ### Un titre    {#mon-identifiant-propre}

        <!-- Autre part dans le texte (avant ou après) -->

        Je peux remonter à [ce titre](#mon-identifiant-propre) pour le relire.

<a name='definitiondesliensenentete'></a>

### Définition des liens en entête

La kramdownisation supporte de définir les liens en entête du fichier à l'aide de la synthaxe :

        [le titre]: le/lien "Le titre du lien"

Cette ligne sera interprêtée mais pas écrite.

<a name='definitiondeslienscourants'></a>

### Définition des liens courants

Pour ce manuel, on utilise la possibilité de [définition des liens en entête](#definitiondesliensenentete) en utilisant le fichier `manuel/utils/definition_liens.md` dont le code sera toujours ajouté au fichier à interpréter.

<a name='utiliserattributsproprespourlien'></a>

### Ajouter des attributs propres

On peut ajouter tout type d'attributs par :

        [titre](lien){:attribut="valeur"}

(mais bon, je ne sais pas trop à quoi ça sert pour LaTex)
