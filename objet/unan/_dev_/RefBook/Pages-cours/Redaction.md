# Rédaction des pages de cours

* [Les Pages semi-dynamiques](#pagesemiautomatiques)
* [Bindage des pages semi-dynamique](#bindagepagesemidyna)

<a name='pagesemiautomatiques'></a>

## Les Pages semi-dynamiques

Les pages semi-dynamiques, dans le dossier `./data/unan/pages_semidyn/` sont les pages qui seront vraiment chargées par l'utilisateur. Elles sont préparées autant qu'elles peuvent l'être, ne reste plus que les textes vraiment dynamiques comme par exemple les endroits où on utilise le pseudo de l'utilisateur.

<a name='bindagepagesemidyna'></a>

## Bindage des pages semi-dynamique

Pour le moment, c'est l'instance de la page elle-même qui est bindée à la vue. Mais ce comportement pourrait changer à l'usure, si ça n'est pas intéressant.

Mais on peut bien entendu faire appel aux autres méthodes générales, à commencer par `user`. Donc, dans la vue, on peut utiliser :

    Imaginons que le personnage, <%= user.pseudo %>, entre dans le workshop.

Ce texte sera alors remplacé par le pseudo de l'utilisateur.
