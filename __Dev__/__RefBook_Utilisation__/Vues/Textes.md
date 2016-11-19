# Textes


* [Styles de mise en forme](#stylesdemiseenforme)
* [Exergue de mots](#exerguedemots)
* [Texte en Markdown](#texteenmarkdown)


<a name='stylesdemiseenforme'></a>

## Styles de mise en forme

De nombreux styles sont définis par défaut, qui peuvent être utilisés dans les textes des pages. On les trouve définis dans les fichiers du dossier `./view/css`.

Parmi ceux-là, on peut noter :

    .libelle          Pour des libellés, en span(inline-block) ou div

    .wXXX             Où XXX est un nombre de pixels pour la largeur de l'élément
                      Par exemple, si on veut un libellé de 140px, on peut faire :
                      <span class='libelle w140'>Mon lib</span>

<a name='exerguedemots'></a>

## Exergue de mots

On peut mettre des mots en exergue facilement dans un texte en utilisant la méthode `String#with_exergue(&lt;searched&gt;)`.

Cela met tous les mots ou expressions trouvées dans des `span.motex` qui sont par défaut en rouge et gras (cf. `./view/css/common/textes.sass`).

`&lt;searched&gt;` peut être indifféremment un :

* un `String`. Ce sera le texte exact recherché.
* une expression régulière `RegExp` qui sera évaluée sur le texte.
* un `Hash` contenant : `{content: "&lt;l'expression recherchée&gt", whole_word: true/false, exact: true/false, not_regular: true/false}`, qui permettra de construire l'expression régulière évaluée sur le texte.

Détail des valeurs du Hash :

    :content          Le contenu, forcément un string, même si c'est une
                      expression régulière. Mettre "des?", pas /des?/
    :whole_word       Si true, recherche du mot entier.
    :exact            Si true, distinction entre minuscules et majuscules
    :not_regular      Si true, ce N'est PAS une expression régulière qui est
                      fournie, donc elle sera escapée avant d'être introduite
                      dans l'expression régulière (entendu qu'on aura une
                      expression régulière même si ça n'en est pas une, pour
                      les recherches non exact et whole word).


Noter que la méthode va mettre dans la variable `@iterations_motex` du string retourné le nombre d'itérations trouvés. Donc on peut faire :

    str = str.with_exergue("un mot")
    iterations = str.instance_variable_get('@iterations_motex')
    # => Nombre d'itérations de "un mot" dans str

<a name='texteenmarkdown'></a>

## Texte en Markdown

On peut transformer n'importe quel texte au format Markdown à l'aide de la méthode :

        String#markdown
        String#kramdown

Par exemple :

        code = <<-MD
        ### Un titre

        Pour voir
        : Une liste de description

        Autre titre
        : Un autre titre

        ^
        MD

        code.kramdown
        # => Produira

        <h3>Un titre</h3>

        <dl>
          <dt>Pour voir</dt>
          <dd>Une liste de description</dd>
          <dt>Autre titre</dt>
          <dd>Un autre titre</dd>
        </dl>
