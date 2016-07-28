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

Cela gère tout le système de commentaire et d'affichage.
