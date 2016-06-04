# Analyses de films

* [Balises scènes et scénier](#balisesscenesetscenier)


<a name='balisesscenesetscenier'></a>

## Balises scènes et scénier

On peut utiliser des balises de la forme `SCENE[numéro|libelle|classe_css]` pour faire référence à des scènes dans un scénier.

Dès que l'affichage détecte un fichier comportant une telle balise, il charge les modules nécessaires pour la gestion de ces scènes. À savoir :

* le module javascript définissant l'objet `Scenes` (en fait, pour le moment, cet objet est toujours chargé puisqu'on le trouve dans `show.js`, un module toujours chargé à l'affichage de l'analyse par `show.(e)rb`),
* le scénier contenant les scènes
