# Aide pour la collection Narration

> Si ce document est modifié, il faut l'ouvrir dans Mou et produire la version HTML.

* [Les livres de la collection](#leslivresnarration)
  * [Estimation du nombre de pages et autres valeurs](#estimationdunombredepagesetautres)
* [Les Pages narration](#lespagesnarration)
  * [Recherche des TODOs](#recherchedestodo)
  * [Check des pages “out” des TDMs](#checkdespagesout)
  * [Création d'une nouvelle page](#creationdunenouvellepage)
* [Les Textes](#lestextes)
  * [Obtenir des balises vers film, livre, mot, etc.](#obtenirbalisesverschoses)
  * [Notes types notes de bas de page](#notesdebasdepage)
  * [Les environnements documents](#environnementsdocuments)
  * [Liste des questions des CHECKUPS](#listedequestionspourcheckup)
  * [Les exemples du livre exemples](#lesexemplesdulivreexemples)
  * [Référence vers autre page](#placerunereferenceaautrepage)
  * [Indiquer des portions en relecture](#portionsrelecture)
  * [Textes types](#lestextestypes)
  * [Images](#utilisationduneimage)
* [Sortie des livres de la collection](#sortiedulivrenarration)
  * [Sortie LaTex de la collection](#sortielatexcollection)

<a name='leslivresnarration'></a>

## Les livres de la collection

<a name='estimationdunombredepagesetautres'></a>

### Estimation du nombre de pages et autres valeurs

Pour estimer le nombre de page de chaque livre, ainsi que le nombre de signes et autres, on peut utiliser l'une de ces commandes dans la [console](admin/console) :

    inventory narration

    etat des lieux narration


<a name='lespagesnarration'></a>

## Les Pages narration


<a name='recherchedestodo'></a>

### Recherche des TODOs

Pour trouver tous les `TODO` des choses à faire sur les pages, on peut utiliser [la recherche](cnarration/search) avec le texte `todo` non exact et dans les textes.

<a name='checkdespagesout'></a>

### Check des pages “out” des TDMs

Pour checker les fichiers physiques qui pourraient ne pas se trouver dans les tables des matières ou les titres, etc. on peut utiliser la commande suivante dans la [console](admin/console) :

    check pages narration out


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

Noter qu'on peut facilement obtenir l'ID de la page/titre en affichant la table des matières du livre (`show livre &lt;référence&gt;`) et en glissant la souris sur le titre ou la page après laquelle il faut insérer le nouveau titre ou la nouvelle page.



<a name='lestextes'></a>

## Les Textes

[Aide Kramdown](http://kramdown.gettalong.org)


<a name='portionsrelecture'></a>

## Indiquer des portions en relecture

Lorsqu'une page a été entièrement corrigée et que du texte est ajouté ou modifier, on peut mettre ce texte entre balises `RELECTURE_ ... _RELECTURE` pour que lui seul soit relu et corrigé.

~~~

  RELECTURE_

  Le passage qui doit être relu et corrigé.

  Il peut faire autant de lignes que voulu.

  _RELECTURE

~~~

Note : penser à modifier le niveau de développement du fichier pour qu'il soit indiqué en lecture pour les correcteurs.

> Des balises HTML `&lt;relecture>` ne sont pas utilisées, car la portion de texte ne serait plus corrigée par le module kramdown et donc le texte ne serait plus mis en forme (kramdown penserait que c'est un texte déjà formaté).

<a name='lestextestypes'></a>

### Textes types

Des textes-types, de préférable en Markdown, insérable n'importe où peuvent être définis dans le dossier :

    ./data/unan/texte_type/cnarration/

Pour les insérer il suffit d'utiliser :

    Cnarration::texte_type "path/relatif/to/file.md"

Le chemin relatif se calcule depuis le dossier `./data/unan/texte_type/cnarration/`.

<a name='lesexemplesdulivreexemples'></a>

## Les exemples du livre exemples

Les exemples du livre exemples peuvent être utilisés n'importe où dans les différents ouvrages. Cela a été inauguré par exemple avec le synopsis de Thelma et Louise.

Pour faire référence à un exemple et insérer son texte dans la page, il suffit d'utiliser la balise `EXEMPLE` avec en paramètre l'adresse relative depuis le dossier `./data/unan/pages_semidyn/cnarration/exemples/_textes_/`.

Par exemple, justement pour le synopsis de Thelma & Louise :

~~~

EXEMPLE[synopsis/Thelma_et_Louise_v1.md]

~~~

<a name='placerunereferenceaautrepage'></a>

### Référence vers autre page

Quand il y a l'ancre, il faut obligatoirement le titre
=>  Si 4 élément => avec ancre
    Si 3 éléments => le titre en dernier
    Si 2 éléments => le titre ou le livre en dernier

@usage

    REF[page_id[|ancre][|titre]]

    REF[page_id]                # Référence par simple ID de page
    REF[page_id|titre]          # Idem avec un titre fourni
    REF[page_id|ancre|titre]    # Avec l'ancre, le titre est OBLIGATOIRE

Pour obtenir facilement une référence à une page, rejoindre la page et cliquer sur le bouton `&lt;-&gt`. Ou utiliser la commande `balise page ...`

<a name='obtenirbalisesverschoses'></a>

## Obtenir des balises vers film, livre, mot, etc.

Pour obtenir ces balises à insérer dans les textes, utiliser la console avec les commandes suivantes :

@syntaxe pour un film

    balise film <portion du titre fr ou original>

@syntaxe pour un mot du scénodico

    balise mot <portion du mot>

@syntaxe pour un livre de la collection

    balise livre <ref book>

@syntaxe pour un livre de la bibliographie

    balise livre <portion de l'id, du titre ou de l'auteur>

@syntaxe pour une page de la collection

    balise page <portion du titre>


<a name='notesdebasdepage'></a>

## Notes types notes de bas de page

On peut insérer des notes dans le texte en se servant des double-crochets. On insère la balise `{{ID}}` à l'endroit où l'on doit trouver le renvoi de note et l'on définit la note à l'aide de `{{ID: NOTE}}` à l'intérieur de deux balises `<!-- NOTES -->` et `<!-- /NOTES -->`.

Attention, ces marques doivent être respectées scrupuleusement.

Exemple :

~~~

  Le texte avec une note {{2}} pour voir si ça marche.

  Un second paragraphe et une autre note {{1}} qui n'est pas indicé
  dans le bon ordre {{3}}.

  <!-- NOTES -->
  {{3: Une troisième note. Peu importe qu'elle soit ici.}}
  {{2: La définition de la note 2.}}
  {{1: La définition de la note 1.}}
  <!-- /NOTES -->

~~~

Ce code produira le texte :

---

Le texte avec la note<sup class='small'>1</sup> pour voir si ça marche.

Un second paragraphe et une autre note<sup class='small'>2</sup> qui n'est pas indicé
dans le bon ordre<sup class='small'>3</sup>.

<div style="border:1px solid #777;width:50%"></div>

  1   La définition de la note 2.<br>
  2   La définition de la note 1.<br>
  3   Une troisième note. Peu importe qu'elle soit ici.

<div style="border:1px solid #777;width:50%"></div>



---

<a name='environnementsdocuments'></a>

### Les environnements documents

Ces environnements permettent de simuler une page de document dans la page.

Dans TextMate, utiliser le snippet `doc->|` pour générer le texte type :

    DOC/<type de document>[ plain]
    # Un titre
    ## Un sous-titre
    ...
    / Légende du document
    /DOC

On trouve comme type de document :

    events      Évènemencier
    synopsis    Synopsis ou document général.
    raw         Document brut (pre)
    rapport     Type rapport
    procedure   Type pour l'aide (cf. dans l'aide générale)
    scenario    Scénario
                On peut alors commencer les lignes par des :
                <LETTRE>:<texte>
                pour formater dans le style d'un scénario à l'aide
                des lettres I (intitulé) A (action), D (dialogue),
                P (nom du personnage) J (note de jeu)

<a name='listedequestionspourcheckup'></a>

### Liste des questions des CHECKUPS

L'idée est que ces checkups soient automatiques, qu'ils rassemblent toutes les questions qui sont posées au fil des pages.

#### Ajout d'une question dans un fichier

Pour enregistrer une nouvelle question, on la marque dans le texte par :

    CHECKUP["<la question>"<|groupe>]

Les `&lt;groupe&gt;` permettent de la classer dans la page en mettant les questions dans des groupes. Par exemple :

    CHECKUP["Ceci est une question générale"|'generalites']

> Note : On peut très bien utiliser aussi ce système pour une liste de consignes par exemple.

#### Affichage des questions du checkup

Une page checkup est une page qui contient le code :

    PRINT_CHECKUP
    # => Affiche toutes les questions, dans l'ordre où elles
    # apparaissent dans le livre, sans classement.

Pour grouper les questions par leur groupe :

    <!-- On met le titre au-dessus de la balise -->
    ## Questions générales

    PRINT_CHECKUP['generalites']

    ## Questions sur les personnages

    PRINT_CHECKUP['personnages']

    ## Autres questions

    PRINT_CHECKUP
    <!--
      Affichera les questions qui restent à afficher.
      Ce fait automatiquement, avec le titre "Autres questions"
      s'il reste des questions dans la liste complète.
    -->

#### Style CSS des questions et de la liste

Les styles pour les questions sont définis dans :

    ./objet/cnarration/lib/required/css/show.sass

#### Explication des checkups

On peut insérer un texte type sur l'explication des checkups en insérant à l'endroit voulu (en général en haut du fichier) la balise :

    EXPLICATION_CHECKUPS

Le texte est un texte type se trouvant dans :

    ./data/unan/texte_type/cnarration/explication_checkups.md

#### Actualisation

Dès qu'un fichier contenant une question est modifié, le programme cherche dans quel fichier de checkup la question doit apparaitre et détruit son fichier ERB pour forcer sa reconstruction la prochaine fois qu'il sera affiché (un lien permet de le faire tout de suite).

<a name='utilisationduneimage'></a>

## Images

    IMAGE[path/relatif|titre optionnel OU 'inline'|legende]

Mettre `inline` pour que l'image soit en ligne, `fleft` pour "floattant à gauche" ou `fright` pour "flottant à droite". Dans le cas contraire, elle apparaitra toujours au milieu, sur un paragraphe.

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

Il sera ajouter en légende.

<a name='sortiedulivrenarration'></a>

## Sortie des livres de la collection

Par défaut, la collection est créée en HTML et sort sur le site de LA BOITE À OUTILS DE L'AUTEUR. Il suffit de charger une page pour qu'elle se construise le cas échéant.

<a name='sortielatexcollection'></a>

### Sortie LaTex de la collection



Pour faire une sortie Latex, exécuter la commande :

    narration sortie latex[ ref_book]

Tous les livres :

    narration sortie latex

Le livre documents :

    narration sortie latex documents
