# Édition des fichiers

* [Éditer le contenu d'un fichier avec l'éditeur interne](#editeravecediteurinterne)



<a name='editeravecediteurinterne'></a>

## Éditer le contenu d'un fichier avec l'éditeur interne


On peut utiliser la méthode `lien.edit_text` pour éditer le texte à l'intérieur de l'éditeur de l'application RestSite.

    lien.edit_text(<path/to/file>, <{options}>)


    options peut contenir
    ---------------------

      :titre    Le titre à donner au lien
                Sinon "Édition du contenu de path/to/file"

      Tous les autres attributs possible de la balise <a>.
