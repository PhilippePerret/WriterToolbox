# Méthodes de test des valeurs numériques


* [`eq` & dérivées](#eqandderirvees)
* [`bigger_than` & dérivées](#biggerthanetderivees)

* [Sujets et objets des tests](#sujetetobjetdestests)
<a name='sujetetobjetdestests'></a>

## Sujets et objets des tests

Pour toutes les méthodes suivantes, comme pour presque toutes les méthodes qui s'appliquent à un type “normal”, on peut définir en `options` (second paramètre) les valeurs du sujet (ie ce qui est comparé) et de l'objet (ie à quoi le sujet est comparé). Cela permettra de faire des messages plus explicitent.

~~~ruby
  
  count = 5
  count.eq(3)
  # => Produira l'erreur "5 devrait être égal à 3."
  count.eq(3, {sujet: "La valeur X"})
  # => Produira l'erreur "La valeur X devrait être égal à 3."
  count.eq(3, {sujet: "X", objet:"Y"})
  # => Produira l'erreur "X devrait être égal à Y (3), il est égal à 5."
  
  # Si l'objet est masculin, mettre "au" devant l'objet :
  count.eq(3, {sujet: "X", objet: "au nombre d'essais"})
  # => Produira l'erreur "X devrait être égal au nombre d'essais (3), 
  #                       il est égal à 5."
  
  
  
~~~

<a name='eqandderirvees'></a>

## `eq` & dérivées

Tests sur une valeur numérique. Par exemple&nbsp;:

~~~ruby

  test_base "users.users" do
    count.eq(3)
    # Produit un succès s'il y a 3 users seulement
    
    if count.eq?(3)
      ... joué si le nombre de users est de 3 ...
    end
  end
~~~

~~~
          
FORMES    ____________________________________________
          ||      Droite      |      Négative        |
----------||------------------|----------------------|
  Simple  ||      eq(?)       |       not_eq(?)      |
----------||------------------|----------------------|
  Pluriel ||        ---       |         ---          |
------------------------------------------------------

~~~

<a name='biggerthanetderivees'></a>

## `bigger_than` & dérivées

Permet de tester si la valeur est supérieure à une autre.

~~~ruby

  <valeur>.bigger_than(<expected>, <options>)
    
~~~

~~~ruby

  test_base "users/users" do
    nombre_inscrits = count
    
    nombre_inscrits.bigger_than(3, {sujet: "Le nombre d'utilisateurs"})
    # Produit l'erreur "Le nombre d'utilisateurs devrait être 3, il est égal à 5"
    
    where = "CAST(SUBSTR(options,1,1)) IN INTEGER > 1"
    options = {
      sujet: "Le nombre d'administrateur",
      objet: "au nombre d'inscrits"
    }
    count(where: where).not_bigger_than(nombre_inscrits, options)
      # Génère la failure : "Le nombre d'administrateur ne devrait 
      # pas être supérieur au nombre d'inscrits" en cas d'erreur.
  end
~~~

~~~
          
FORMES    ____________________________________________
          ||      Droite      |      Négative        |
----------||------------------|----------------------|
  Simple  ||  bigger_than(?)  |  not_bigger_than(?)  |
----------||------------------|----------------------|
  Pluriel ||        ---       |         ---          |
------------------------------------------------------

~~~

