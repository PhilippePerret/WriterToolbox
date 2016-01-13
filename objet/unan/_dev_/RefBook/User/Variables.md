# Variables de l'user

* [La table `variables`](#tablevariables)
* [Définir la valeur d'une variable](#definirvaleurvariables)
* [Obtenir la valeur d'une variable](#obtenirlavaleurdunevariable)

<a name='tablevariables'></a>

## La table `variables`

La table `variables` est une table propre à un programme (et donc à un utilisateur) qui conserve les valeurs ne n'importe quelle variable.

Elle a été inaugurée pour consigner le nombre de messages forum, de pages de cours à lire, de travaux à exécuter pour l'auteur, sans avoir à fouiller les autres bases pour obtenir ces informations.

Elle ne contient que 3 colonnes (sans compte la colonne :id pour la compatibilité avec `BdD`) qui sont :

      Colonne         Description                   Exemple
    ---------------------------------------------------------------------
      :name           Nom de la variable            'pages_ids'
      :value          La valeur enregistrée         "[1,23,10]"
      :type           Le type de la valeur          5 (pour : Array)
    ---------------------------------------------------------------------

Il est donc possible d'enregistrer tout type de variable scalaire et de les retrouver dans le type initial, qui peut être `String`, `Fixnum`, `Bignum`, `Float`, `TrueClass`, `FalseClass`, `NilClass`, `Array` ou `Hash`.

<a name='definirvaleurvariables'></a>

## Définir la valeur d'une variable

    set_var <var_name>, <var_value>
    set_var <var_name> => <var_value>

Par exemple (toutes ces tournures sont équivalentes) :

    set_var :nombre_pages, 12
    set_var nombre_pages: 12
    set_var :nombre_pages => 12

Noter que le nom de variable peut être soit un `String` soit un `Symbol`.

Noter qu'on peut définir plusieurs variables par ce biais mais que chacune sera enregistrée par une requête séparée, donc attention au temps.

<a name='obtenirlavaleurdunevariable'></a>

## Obtenir la valeur d'une variable

    get_var var_name

Par exemple :

    pages_id = get_var :pages_cours

Noter que là aussi `var_name` peut être indifféremment un `String` ou un `Symbol`.
