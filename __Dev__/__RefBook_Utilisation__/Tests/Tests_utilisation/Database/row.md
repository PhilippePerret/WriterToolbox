# Case-objet `ROW`

* [Méthodes fonctionnelles de l'objet `row`](#methodesfonctionnellesderow)
* [Méthodes de test de l'objet `row`](#methodesdetestdelobjetrow)

`row` est un objet de classe `SiteHtml::TestSuite::DBase::Row` qui contient des méthodes de case et des méthodes de gestion&nbsp;:

~~~ruby

row(...).exists
row(...).delete
row(...).insert(...data...)
row(...).has(...data...)

~~~

Noter que ces méthodes fonctionnent aussi bien online qu'offline donc qu'il faut être particulièrement prudent, même si des backups sont produits.

> Rappel : Pour rendre un test uniquement en offline, il suffit d'ajouter au-dessus du fichier de tests `only_offline`.


<a name='methodesfonctionnellesderow'></a>

## Méthodes fonctionnelles de l'objet `row`

* [Méthode `Row#data`](#methodeerowdata)
* [Méthode `Row#set`](#methoderowset)

<a name='methodeerowdata'></a>

### Méthode `Row#data`


Retourne toutes les données sans exception de la rangée concernée.

~~~ruby

  thdata = row(...).data
  # Noter que c'est un THash, c'est-à-dire un hash qui pourra
  # être testé.

~~~

La valeur retournée est un `THash`, pas un `Hash` donc on peut utiliser sur lui toutes les méthodes normales des `Hash` mais en plus les case-méthodes propres, à commencer par `has`, `has_not` etc. pour vérifier qu'il y a bien ces données.


<a name='methoderowset'></a>

### Méthode `Row#set`

Permet de définir la valeur d'une rangée.

~~~ruby

  r = row(12)
  r.set(prop1: valeur1, prop2: valeur2, ... propN: valeurN)

~~~


---------------------------------------------------------------------


<a name='methodesdetestdelobjetrow'></a>

## Méthodes de test de l'objet `row`

### Méthode `has` & dérivées

~~~ruby

    row.has(<hash de données>)

~~~

Produit un succès si la rangée contient les données spécifiées dans le hash de données.
