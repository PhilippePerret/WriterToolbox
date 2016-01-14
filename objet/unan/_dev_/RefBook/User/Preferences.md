# Préférences utilisateur

* [Convention de nommage](#conventionpourlesnoms)
* [Méthodes `preference` et `preference=`](#lamethodepreferences)
* [Relève de toutes les préférences](#relevedetouteslesprefs)


<a name='conventionpourlesnoms'></a>

## Convention de nommage

Par convention, tous les noms de préférence sont enregistrées dans la table `variables` avec **un nom commençant par “pref_”**.

L'identifiant de cette préférence, utilisé par et dans les méthodes fait abstraction de ce “pref_”.

Par exemple, on utilise dans le code la préférence `bureau_after_login` mais dans la table `variables` la donnée est enregistrée au nom de `pref_bureau_after_login`.

**Note : Cela permet simplement de reconnaitre ce type de variable dans la table et de, par exemple, pouvoir toutes les relever d'un coup lorsque ce sont les préférences qu'on doit régler.**

<a name='lamethodepreferences'></a>

## Méthodes `preference` et `preference=`

Les méthodes `User#preference` et `User#preferences=` permettent d'enregistrer les préférences de l'user :

    user.preference= <pref id>, <pref value>

    ou

    user.preference= <pref id> => <pref_value>

Pour récupérer la valeur :

    user.preference(<:pref id>[, valeur défaut])

Par exemple :

    user.preference(:bureau_after_login)
    # => true s'il faut rejoindre le bureau "Un an un script" après
    # l'identification.


<a name='relevedetouteslesprefs'></a>

## Relève de toutes les préférences

On peut relever toutes les préférences d'un coup à l'aide de la méthode `User#preferences`. On peut faire ensuite appel à la méthode `User#preference` pour obtenir une valeur, de façon tout à fait normale.

Note : En fait, faire appel à la méthode `User#preferences` évite simplement de faire des appels trop nombre d'affilée à la table `variables`, lorsque plusieurs préférences doivent être utilisées.
