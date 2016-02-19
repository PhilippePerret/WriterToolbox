# Textes


* [Styles de mise en forme](#stylesdemiseenforme)
<a name='stylesdemiseenforme'></a>

## Styles de mise en forme

De nombreux styles sont définis par défaut, qui peuvent être utilisés dans les textes des pages. On les trouve définis dans les fichiers du dossier `./view/css`.

Parmi ceux-là, on peut noter :

    .libelle          Pour des libellés, en span(inline-block) ou div

    .wXXX             Où XXX est un nombre de pixels pour la largeur de l'élément
                      Par exemple, si on veut un libellé de 140px, on peut faire :
                      <span class='libelle w140'>Mon lib</span>
