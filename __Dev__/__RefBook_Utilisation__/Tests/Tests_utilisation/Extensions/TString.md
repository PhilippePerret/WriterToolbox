# Classe de test `TString`

OBSOLÈTES : MAINTENANT, UTILISER SIMPLEMENT LE STRING AVEC LES MÉTHODES `is`, `is_not`, `has` et `has_not`.

* [Case-méthode `has` & dérivées](#casemethodehas)
* [Case-méthode `is` & dérivées](#casemethodeisestderivees)
* [Test d'une valeur String quelconque](#testdunevaleurstringquelqconte)

Les objets `TString` sont des instances de `String` augmentées.

Elles répondent aux méthodes de test :


<a name='casemethodehas'></a>

## Case-méthode `has` & dérivées

> Note : Le nom `has` est choisi pour la cohérence avec les autres méthodes plutôt que `contains` ou autre `include`.

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

<a name='testdunevaleurstringquelqconte'></a>

## Test d'une valeur String quelconque

Les tests quels qu'ils soient nécessitant de connaitre la méthode-test courante, on ne peut pas faire de tests directs sur les `String` :

~~~ruby

  # IMPOSSIBLE
  "Impossible".is("impossible") # <= IMPOSSIBLE
  # IMPOSSIBLE

~~~

Il faut passer par la classe `TString` :

~~~ruby

test_route "ma/route" do

  str = TString.new(self, "Possible")
  str.is("possible")
  
end

~~~

En revanche, on peut tout à fait utiliser `[]` :

~~~ruby

  str = TString.new(self, "Possible")
  
  str[0].is("P", {strict: true})
  # => Produit un succès
  
~~~

Noter cependant que ce système utilise la valeur de `SiteHtml::TestSuite::TestFile.current_test_method` qui maintient la test-méthode courante, ce qui peut parfois poser problème dans des situations particulières.

