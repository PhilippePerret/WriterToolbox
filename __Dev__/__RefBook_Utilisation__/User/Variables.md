# Variables de l'user

* [La table `variables`](#tablevariables)
* [Définir la valeur d'une variable](#definirvaleurvariables)
* [Définir les valeurs de plusieurs variables](#definirplusvariables)
* [Obtenir la valeur d'une variable](#obtenirlavaleurdunevariable)
* [Récupérer plusieurs valeurs d'un coup](#recupererplusieursvaluers)

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

<a name='definirplusvariables'></a>

## Définir la valeur de plusieurs variables

Utiliser la méthode :

    set_vars <{hash_data_to_save}

Par exemple :

    set_vars(pref_saved_id: true, pref_next_after: false, update: NOW.to_i)

Noter que la méthode sait faire la distinction entre une valeur existante et une valeur inexistante et ne sauve pas une valeur identique.


<a name='obtenirlavaleurdunevariable'></a>

## Obtenir la valeur d'une variable

    get_var var_name

Par exemple :

    pages_id = get_var :pages_cours

Noter que là aussi `var_name` peut être indifféremment un `String` ou un `Symbol`.

<a name='recupererplusieursvaluers'></a>

## Récupérer plusieurs valeurs d'un coup

On peut obtenir plusieurs valeurs en utilisant la méthodes :

    [user.]get_vars( <[noms des variables]>[, as_real_value = (true|false)] )

Par exemple :

    get_vars(['pref_real_name', 'message_quotidien'], true)

Retournera :

    {
      :pref_real_name     => true,
      :message_quotidien  => "Ceci est le message du jour"
    }

Noter que le {Hash} retourné contient les valeurs réelles car le second paramètres est `true`. Si le second paramètre était `false` ou n'avait pas été précisé, la méthode aurait retourné :

    {
      :pref_real_name => {id: 12, name: "pref_real_name", type: 7, value: "1"},
      :message_quotidien => {id: 256, name: "message_quotidien", type: 0, value: "Ceci est le message du jour"}
    }
