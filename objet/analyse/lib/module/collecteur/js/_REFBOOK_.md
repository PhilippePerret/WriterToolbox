Dernière note : N0007

# Javascript pour la collecte

Ces fichiers permettent de gérer l'outil de collecte en ligne.

## Les objets DataField

Les `objets DataField` sont les objets javascript des types d'élément comme `Persos` (pour les personnages) ou `Brins` (pour les brins). Tous ces éléments partagent des méthodes et des propriétés par l'objet JS `DataField`.

Pour pouvoir être un objet `DataField`, l'objet JS doit posséder les propriétés suivantes :

* `name`. Le nom de l'objet. Par exemple `Persos` pour les personnages ou `Brins` pour les brins.
* `type` ('personnage' pour la classe `Persos`),
* `items` (tous les éléments, dans le même format),
* `tag`. La valeur balise, p.e. “PERSO” pour les personnages, “BRIN” pour les brins.
* `champ_data`. Set jQuery du champ définissant les données de l'élément. Note : ce champ doit avoir normalement en ID le `type` pluriel (`personnages` pour le type `personnage` de l'objet JS `Persos`)
* `strings`. Pour définir tout ce qui concerne les strings :
  {pluriel: 'le nom au pluriel'}
* `default_data`. Hash des données par défaut (à la création d'un nouvel élément dans la relève des données dans le champs — cf. `DataField.get_items()`)

Il doit répondre aux méthodes suivantes :

* `initialize`. Permet notamment de définir le champ `champ_data` qui contient les données.

## Notes

N0001   DataField.insert_balise

Cette méthode permet d'insérer une balise de la forme `[PERSO#identifiant]` dans le champ de collecte pour les personnages, les brins, etc.

Pour pouvoir fonctionner, l'objet (envoyé en premier argument de la méthode) doit répondre aux méthodes et propriétés des objets `DataField` (cf. plus haut)


`last_indexes` et `timers_last` permettent de pouvoir confirmer le choix de l'élément. Par exemple, pour les personnages, on ne se souvient pas forcément du bon numéro. Donc, on essaie avec l'indice qu'on pense (par exemple 5) et si ça n'est pas le bon, on peut en essayer un autre. Quand on a le bon, on retape le numéro pour le confirmer, ce qui permet de déselectionner la balise et de place le curseur après pour pouvoir l'écriture.


N0002

Par défaut, tous les capteurs d'évènements keypress passe par la méthode commune qui permet de gérer les méthodes communes, par exemple la création d'un nouvel item, le passage d'une propriété à l'autre, etc.

N0003

L'objet courant `currentObjet` permet de connaitre le focus de certaines opérations. Il est défini au focus dans un champ et doit être donc ajouté à la méthode `focus` du champ à l'initialisation.

N0004

Pour le moment, le `type` doit impérativement correspondre à la balise définissant l'élément en minuscule.

Par exemple, pour les personnages, le type est `personnage` et la définition se fait par :

~~~

PERSONNAGE:identifiant
  PRENOM: Prénom
  etc.

~~~

N0005

window.common_key_press_shortcuts

C'est la méthode de captation des évènements commune à tous les panneaux, qu'on soit ou non dans un champ d'édition. C'est par exemple dans cette méthode qu'est testé le `CTRL + A` qui affiche l'aide de l'application.

Cette méthode doit être appelée en tout premier lieu dans tout captage d'évènement. Si c'est dans un objet `DataField` (cf. plus haut), elle est automatiquement invoquée, il n'y a rien à faire.

N0006

On doit focusser toujours dans le champ collecte pour forcer le `blur` des champs de données, qui par défaut affichent la liste des éléments. Il faut les blurer avant le reste, avant de passer à une autre liste par exemple.

N0007

On ne doit fermer la boite d'édition de l'élément que lorsque des données ont été définies. Sinon, on la laisse ouverte.

Cela permet, par exemple, de ne pas avoir de problème quand on procède ainsi :

* on demande l'édition des brins pour les copier-coller depuis un fichier. On fait donc `CTRL B`
* on rejoint l'application pour copier le code des brins
* on revient dans Firefox (AVANT : puisqu'on avait changé d'application, on avait donc “bluré” du champ, ce qui l'avait supprimé/caché. Maintenant, comme il n'y a pas d'éléments, la fenêtre d'édition reste ouverte)
* on peut copier-coller le code dans le champ.
