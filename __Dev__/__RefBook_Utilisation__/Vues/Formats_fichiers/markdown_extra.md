# Extra-formatage pour fichiers Markdown

> Avant tout il faut noter que si ces formatages sont définis pour les fichiers Markdown, ils peuvent tout à fait être utilisés par d'autre éléments puisque c'est la classe String qui les définit. Cf. les fichiers du module `./lib/deep/deeper/module/kramdown`.

* [Mise en forme type : Document](#formatagedocument)
* [Les types de document](#lestypesdedocuments)
  * [Cas particulier du scénario](#casparticulierduscenario)
* [Titres et sous-titres](#titreetsoustitre)
* [Légende au document](#ajouterlegendedocumenet)

<a name='formatagedocument'></a>

## Mise en forme type : Document

Cette mise en forme permet de donner l'impression d'avoir un document inséré dans la page.

<a name='lestypesdedocuments'></a>

### Les types de document

> Ces types se définissent après `DOC/+type+`. Par exemple `DOC/events` ou `DOC/scenario`

Les types de documents connus

    events                    Pou run évènemencier
        Les tirets définissent les évènements

    synopsis

    scenario                  Pour un scénario
        On trouve les styles 'action', 'intitule', 'dialogue', 'nom'

    rapport                   Pour Un rapport

CONCEPTION

* Il faut pouvoir définir une sous-classe
  Par exemple : `document.scenario` ou même `scenario`
  `document.evenemencier`
  `document.synopsis`
  `document.sequencier`

<a name='casparticulierduscenario'></a>

### Cas particulier du scénario

Pour le scénario, on utilise la classe en début de ligne en mettant seulement la première lettre. Donc :

    DOC/scenario
    I:INT. BUREAU - JOUR  # => intitulé de scène
    A:Une action ou une description
    N:Un nombre de personnage qui parle
    P:Idem, un nom de personnage qui parle
    J:(Note de jeu)
    D:Le dialogue du personnage.
    /DOC

<a name='titreetsoustitre'></a>

## Titres et sous-titres

Les titres et les sous-titres se gèrent comme pour les documents markdown normaux, à l'aide des `#`.

Note : Penser à laisser TOUJOURS une espace entre les dièses et le titre.

Note : On commence à `# ` même si ce titre va paraitre gros dans le document.

<a name='ajouterlegendedocumenet'></a>

## Légende au document

Pour ajouter une légende au document, on ajoute en dernière ligne :

    /la légende du document.

Par exemple :

    DOC/scenario
    ... ici le scénario ...
    /Un exemple de scénario
    /DOC

Cette légende sera ajoutée en petit sous le document, en italique.
