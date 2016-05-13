# Divers

* [Balise title de page](#titledepage)

<a name='titledepage'></a>

## Balise title de page

La balise `<title>` de la page HTML permet d'afficher le titre dans la fenêtre du navigateur mais aussi dans l'historique de navigation. Pour la définir, il convient tout d'abord de définir dans le fichier de configuration la donnée `title_prefix` :

    # Dans ./objet/site/config.rb

    site.title_prefix = "<le prefix du site, court si possible>"

Ensuite, on utilise dans les pages ou dans un fichier requis de l'objet :

    page.title = "<le titre à donner>"

> On peut par exemple créer un fichier : `./objet/<objet>/lib/required/constants.rb`.

Cela produira l'écriture du titre :

    <title>site.title_prefix | page.title</title>

Noter que le séparateur peut être défini dans le confier de configuration par :

    site.title_separator = " | " # mettre un autre caractère si nécessaire

Noter qu'il n'y aura pas d'espaces ajoutés.
