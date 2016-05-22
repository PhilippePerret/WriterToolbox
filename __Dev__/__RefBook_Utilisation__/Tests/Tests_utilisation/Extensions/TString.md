# Classe de test `TString`

Les objets `TString` sont des instances de `String` augmentées.

Elles répondent aux méthodes de test&nbsp;:

* [Case-méthode `has` & dérivées](#casemethodehas)

<a name='casemethodehas'></a>

## Case-méthode `has` & dérivées

> Note&nbsp;: Le nom `has` est choisi pour la cohérence avec les autres méthodes plutôt que `contains` ou autre `include`.

~~~ruby

  t = TString.new("Mon string")
  t.has("str")
  # => succès
  t.has(["Mon", "n s", "ing"])
  # => succès
  t.has(/n ?s/)
  # => succès
  
  t.has?("Mon strin")
  # => true
  
* [Case-méthode `is` & dérivées](#casemethodeisestderivees)
<a name='casemethodeisestderivees'></a>

## Case-méthode `is` & dérivées

@usage

~~~ruby

  t = TString.new("Mon string")
  
  t.is("Mon string")
  # => produit un succès
  t.is("Mon STRING")
  # => produit une failure
  
  t.is?("Mon Hash")
  # => false
  
  t.is_not("Mon String")
  # => Produit un succès (pas strictement égal)
  
~~~
