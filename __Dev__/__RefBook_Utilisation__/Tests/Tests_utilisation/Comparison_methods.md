# Les méthodes de comparaison

* [`is`](#methodeobjectis)
* [`is_not`](#methodeobjectisnot)
* [`has`](#methodeobjecthas)
* [`has_not`](#methodeobjecthasnot)
* [`is_instance_of`](#methodeobjectisinstanceof)
* [Les options des méthodes de comparaison](#methodesobjectsoptions)
  * [Sujet de la comparaison](#sujetexactedutest)
  * [Objet de la comparaison](#objetdelacomparaison)

Ce sont des extensions de la classe `Object` donc toutes les classes en héritent.

<a name='methodeobjectis'></a>

## `is`

    <sujet>.is(<expected>[, <options>])

Pour les options, voir [les options des méthodes de comparaison](#methodesobjectsoptions).

<a name='methodeobjectisnot'></a>

## `is_not`

Pour les options, voir [les options des méthodes de comparaison](#methodesobjectsoptions).


<a name='methodeobjecthas'></a>

## `has`

Pour les options, voir [les options des méthodes de comparaison](#methodesobjectsoptions).


<a name='methodeobjecthasnot'></a>

## `has_not`


Pour les options, voir [les options des méthodes de comparaison](#methodesobjectsoptions).

<a name='methodeobjectisinstanceof'></a>

## `is_instance_of`

Vérifie que le sujet soit bien de la classe voulue.

        <sujet>.is_instance_of(<classe>[, <option>])

Pour les options, voir [les options des méthodes de comparaison](#methodesobjectsoptions).

---------------------------------------------------------------------

<a name='methodesobjectsoptions'></a>

## Les options des méthodes de comparaison

Les options sont le second argument qu'on peut transmettre —&nbsp;ou pas&nbsp;— aux méthodes de comparaison de la classe `Object`.

    :strict       Si true, la recherche est stricte (default: false)
                  Donc "mon string" sera différent de "Mon String"
    :sujet        Pour le message de retour, le nom à employer. Si non fourni,
                  c'est la valeur du sujet qui sera utilisée. 
                  Pour ajouter la valeur cf. ci-dessous.  
    :objet        Pour le message de retour, le nom à utiliser pour désigner la
                  la valeur de retour. Noter que la valeur sera presque toujours
                  ajoutée.
                  
<a name='sujetexactedutest'></a>

### Sujet de la comparaison

Par défaut, c'est la valeur à comparer qui est affichée dans le message.

        1.is(1)
        # Affiche "1 est égal à 1."
      
Si l'argument d'options définit un sujet, c'est ce sujet qui est utilisé.

        1.is(1, {sujet: "Le premier chiffre"})
        # Affiche "Le premier chiffre est égal à 1."

Si le sujet défini dans les options doit afficher la valeur actuelle, il suffit d'ajouter `%{value}` à l'endroit voulue.

        1.is(1, {sujet "Le premier chiffre à %{value}"})
        # Affiche "Le premier chiffre à 1 est 1"

<a name='objetdelacomparaison'></a>

### Objet de la comparaison

Il en va de même pour l'objet de la comparaison que pour la comparaison&nbsp;:

La valeur par défaut est la valeur elle-même.

        1.is(2)
        # Affiche "1 devrait être égal à 2."
        
L'objet peut être défini par la propriété `objet` dans les options&nbsp;:

        1.is(2, {objet: 'l’objet deuxième'})
        # Affiche "1 devrait être égal à l'objet deuxième."

Et pour afficher aussi la valeur attendue, utiliser `%{value}` pour placer la valeur.

        1.is(2, {objet: 'L’objet deuxième (%{value})'})
        # Affiche "1 devrait être égal à l'objet deuxième (2)."
