# Construction des vues

* [Emplacement des pages](#emplacementdespages)

Toutes les vues sont dynamiques car elles contiennent souvent des éléments personnalisés, comme par exemple les exemples avec l'user courant.

Cependant, il y a certains traitements qui peuvent être lourds, comme par exemple le système de balisage (liens vers un exercice, vers un questionnaire, vers une autre page de cours, vers une tâche).

Faut-il imaginer des fichiers intermédiaires qui ne conserveraient que les éléments dynamiques.

    PAGE ORIGINALE (le plus souvent ERB)

          ||
          ||      Traitement des liens-balises, etc. Ils sont remplacés par
          ||      des vrais liens.
          \/

    PAGE SEMI-DYNAMIQUE (peut-être du contenu avec %{variable})

          ||
          ||      Traitement des quelques éléments dynamiques comme les
          ||      dates où les pseudos du lecteur de la page.
          \/

    PAGE FINALE ENVOYÉE

Aucun contrôle n'est fait pour actualiser les pages semi-automatiques. Il faut le faire explicitement.

=> Un bouton-lien pour construire la page semi-dynamique.

<a name='emplacementdespages'></a>

## Emplacement des pages

Les pages **originales** se trouvent dans le dossier `./data/unan/page_cours`.

Les pages **semi-dynamiques** se trouvent dans le dossier `./data/unan/page_semi_dyna`.

Les pages **finales** sont toujours envoyées à la volée.

* [Constructeur de page](#constructeurdepage)
<a name='constructeurdepage'></a>

## Constructeur de page

C'est le module `./objet/unan_admin/page_cours/build.rb` qui se charge de construire la page semi-dynamique. Puis il redirige vers la page précédente, qui est certainement l'édition du contenu de la page.
