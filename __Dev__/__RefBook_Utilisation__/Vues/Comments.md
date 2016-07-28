# Comments

La classe `Comments` permet de gérer les commentaires sur les pages du site.

* [Rendre une page sensible aux commentaires](#rendreunepagesensibleauxcommentaires)




<a name='rendreunepagesensibleauxcommentaires'></a>

## Rendre une page sensible aux commentaires

Pour rendre une page sensible aux commentaires, il suffit d'ajouter :

    enable_comments

… en haut de sa vue.

Par exemple :

    <%
    # Une vue pour afficher quelque chose
    %>

    <% enable_comments %>

Ensuite, tout se gère tout seul.


* [Valider des commentaires](#validerdescommentaires)
<a name='validerdescommentaires'></a>

## Valider des commentaires

Par défaut — et pour le moment — les commentaires doivent être validés. Pour ce faire, il y a deux solutions :

* La première consiste à utiliser le lien contenu dans le mail envoyé à l'administration au dépôt d'un commentaire. Ce mail contient un lien activant le ticket créé à l'enregistrement du commentaire.

* La seconde consiste à rejoindre la liste de tous les commentaires, qu'on peut trouver à la route : `page_comments/list?in=site`. Cette page peut être atteinte directement depuis le tableau de bord d'administration.
