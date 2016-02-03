#Manuel pour `BdD`


* [Création d'une base de données](#creation_dune_nouvelle_base_de_data)
* **Les tables**
  * [Test de l'existence d'une table](#test_existence_dune_table)
  * [Création d'une table](#creation_dune_table_dans_base_de_donnees)
  * [La clause WHERE](#la_clause_where_avec_request)
  * [Ajout d'une nouvelle donnée (INSERT)](#ajout_dune_donnee_dans_une_table)
  * [Récupération de données (SELECT)](#recuperation_de_donnees_dans_la_table)
  * [Méthode `GET` pour une donnée unique](#recuperer_des_donnees_avec_methode_get)
* [Modification des données (SET/UPDATE)](#modification_des_donness)
  * [Destruction d'une donnée (DELETE)](#destruction_dune_donnee)
  * [Destruction de toutes les données (`pour_away`)](#destruction_de_toutes_les_donnees)
  * [Retourner le nombre de rangées (count)](#retourner_le_nombre_de_rangees)

* [Appels directs de méthodes `BdD`](#appel_direct_de_fonction_bdd)
  * [Relever des valeurs avec `BdD::execute`](#relever_valeurs_avec_execute)
  * [Arguments passés à `BdD::execute`](#bdd_execute_explication_arguments)

* [Module de méthodes d'instance d'objet](#modules_de_methode_dinstance_de_classe)
  * [Acquisition des méthodes](#modules_de_methodes_dinstance_acquisition)
  * [Méthodes et propriétés requises](#modules_de_methodes_dinstance_requis)
  * [Méthode `data`](#module_methodes_objet_methode_data)
  * [Méthode `get`](#module_methodes_objet_methode_get)
  * [Méthode `save`](#module_methodes_objet_methode_save)
  * [Méthode `delete`](#module_methodes_objet_methode_delete)

* [Annexes](#annexes)
  * [Notes de programme](#notes_de_programme)
  * [Débuggage des requêtes](#debuggagedesrequetes)


Maintenant, j'utilise les bases SQLite3 pour les bases de données plutôt que les PStore.



<a name='creation_dune_nouvelle_base_de_data'></a>

##Création d'une base de données

Utiliser le code :

    instance_base = BdD::new "path/to/base/de/donnees"

Le fichier physique de la base sera créé dès l'instanciation, car une table `__column_names__` va y être créée pour conserver les noms des colonnes de chaque table à leur création.


<a name='test_existence_dune_table'></a>

##Test de l'existence d'une table

Soit une base de donnée :

    bdd = BdD::new "./path/to/my.db"

On test l'existence d'une table avec&nbsp;:

    bdd.has_table?( "<nom_de_la_table>" )

    OU

    bdd.table_exist?( "<nom_de_la_table>" )

    OU

    BdD::table_exist? bdd, "<nom_table>"

    OU

    BdD::Table::exist?


<a name='creation_dune_table_dans_base_de_donnees'></a>

##Création d'une table dans une BdD

Code exemple :

    # La database qui contient la table
    bdd = BdD::new "path/to/bdd.db"

    # Instanciation de la table
    table = BdD::Table::new bdd, "ma_nouvelle_table"

    # Définition des colonnes
    table.define(
      "col1" => {type: <le type>[, constraint: <la contrainte>]},
      "col2" => {type: <le type>}
      etc.
      )

    # Création de la table
    table.create

Noter que la méthode `define` ajoute automatiquement la colonne `id` en primary key et autoincrement si elle n'est pas définie.

Pour la définition des colonnes, par exemple&nbsp;:

    table.define(
      "mot"       =>  {type: "VARCHAR(100)"},
      :image      =>  {type: "BLOB", constraint: "NOT NULL"},
      "uploaded" =>   {type: "BOOLEAN", default: "0"}
      )
      # Note: la colonne id est automatiquement créée
      # Note: On peut avoir des clés string ou symbol

###Valeur par défaut

Les valeurs par défaut sont définies par la propriété `:default` dans le `Hash` passé à `<table>.define`. Sa valeur doit être exactement ce qui sera copié dans la requête. Donc pour une chaine de caractères&nbsp;:

      default: "\"LA CHAINGE\""

Tandis que pour un nombre ou autre&nbsp;:

      default: "8"        OU MEME :     default: 8
      default: "NULL"


<a name='la_clause_where_avec_request'></a>

##La clause WHERE

La clause `WHERE` permet de définir les rangées à remonter de la base.

Avec BdD, elle peut se définir de deux façons&nbsp;:

* Explicitement en string. Par exemple `where: "ma_colonne = 'une valeur'"`
* Par un `Hash`. Par exemple `where: {ma_colonne: 'une valeur'}`

Pour protéger la table, il vaut mieux utiliser&nbsp;:

    where: "ma_colonne = ?", values: ['une valeur']


<a name='ajout_dune_donnee_dans_une_table'></a>

##Ajout d'une donnée

Soit `table` la table EXISTANTE instanciée par :

    bdd = BdD::new "path/to/database.db"
    table = BdD::Table::new bdd, "nom_de_la_table"

On ajoute des données à l'aide de :

    table.insert <ARRAY de HASH de données>
    OU
    table.insert <HASH de donnée>
    OU
    table << <array de hashes de données>
    OU
    table << <HASH de donnée>

Les méthodes retourne le **nouvel ID créé** si une seule donnée a été transmise, ou une liste d'IDs si plusieurs données ont été transmises ou NIL si un problème est survenu.

Pour une donnée unique, on envoie le hash de ses valeurs (qui doivent être conformes). Par exemple&nbsp;:

    table << {mot: "Le mot", description: "La description du mot"}
    # => nouvel id

Pour plusieurs données, on envoie l'Array de ses hash de données, par exemple&nbsp;:

    arr_data = [
      {mot: "un mot"},
      {mot: "autre mot 14", description: "avec une description"},
      {mot: "ce mot", description: "Cette descritpion."}
    ]
    table << arr_data
    # => [liste des identifiants ID créés]

<a name='recuperation_de_donnees_dans_la_table'></a>

## Récupération de données (SELECT/GET)

Méthodes :

* `select[ <params>]` # => Array des données
* `get <id>[, <liste keys>]` # => Hash des données
* `>> <param>` # => Array des données

Soit `table` la table EXISTANTE instanciée par :

    bdd = BdD::new "path/to/database.db"
    table = BdD::Table::new bdd, "nom_de_la_table"

On récupérer des données à l'aide de la méthode `select` ou `>>`&nbsp;:

    resultat = table.select <params>
    OU
    resultat = table.get <ID>, <array keys>
    OU
    resultat = table >> <params>

Sans arguments, la méthode retourne toutes les colonnes de toutes les rangées de la table.

Noter que la grande différence entre `select` (ou `>>`) et `get`, c'est que `select` retourne une liste d'array des valeurs tandis que `get` retourne un Hash de la donnée, où les clés sont des symboles.

Avec un premier argument Hash, permet d'affiner la recherche et le retour&nbsp;:

    <param> = {
      keys:     {Array} Des clés à retourner (colonnes),
                # OU :colonnes, :columns
      where:    {String} Condition WHERE de la recherche,
      limit:    {Fixnum} Nombre maximum de rangées retournées
      offset:   {Fixnum} Décalage de la première rangée
      order:    {String} DESC ou ASC
      values:   {AnyType|Array|Hash} Utilisé soit pour définir les valeurs
                avec INSERT ou UPDATE soit pour définir la recherche d'une
                clause WHERE avec SELECT ou UPDATE.
                Si la donnée est un Array, ce sont des "?" qui sont utilisés pour
                définir la recherche (p.e. `id = ?`), si c'est un hash, ce sont des
                pseudo symbols qui sont utilisés (p.e. `id = :id`) et sinon c'est un
                seul '?' donc une condition unique.
      key:      La clé principale de la donnée dans le hash de retour de toutes
                les données trouvées. En règle générale il s'agit de :id, mais
                on peut spécifier une autre clé.
                Cf. un peu plus bas.
    }

Par exemple&nbsp;:

    table.select
    # => Retourne un Hash de Hash de toutes les données.
      [
        <main clé 1> => {rangée 1}
        <main clé 2> => {rangée 2}
        ...
        <main clé N> => {rangée N}
      ]
    Chaque élément `{rangée x}` contient en clé le nom de la colonne et en
    valeur sa valeur.

    <main clé> est en général la propriété ID de la table, mais une autre clé
    peut être précisée grâce à :key dans les paramètres.

    Pour n'obtenir que quelques colonnes (propriétés) seulement, on renseigne
    la propriété `colonnes` des arguments passés à select :

    table.select colonnes: [:id, :name]
    # => Retourne un Array de Hash de toutes les données, mais les Hash ne
    # contiendront que les propriétés :id et :name.
      [
        <main clé> => {id: <id>, name: <name>},
        <main clé> => {id: <id>, name: <name>},
        ...
      ]

    Pour n'obtenir que certaines rangées suivant une condition (clause WHERE),
    on utilise la propriété d'argument `where` :

    table.select where: "LEVEL > 100"
    table.select where: {depth: 100}

    La première ligne retournera toutes les propriétés des rangées donc la
    colonne LEVEL est supérieure à 100.
    La seconde ligne retournera toutes les propriétés de toutes les rangées dont
    la propriété `depth` vaut 100.

    table.select where: "LEVEL > ?", values: 100
    # Produit le même résultat que précédemment mais est plus sûr pour une
    # utilisation avec des valeurs d'utilisateur.

    table.select colonnes: [:id], where: "LEVEL > 100"
    # => Retourne tous les identifiants des rangées dont la
    # propriété LEVEL est supérieur à 100

    table select(
        colonnes: [:id, :created_at],
        where:    "level > :level_min AND level < :level_max",
        values:   {level_min: 120, level_max: 200},
        limit:    10 # 10 résultats seulement
      )
   # => Retourne un Hash contenant au maximum 10 rangées de données dont
   #    le niveau level est supérieur à 120 et inférieur à 200
   #    Le hash contient en clé l'ID de la rangée et en valeur un Hash contenant
   #    ses données { :id, :created_at }

<a name='recuperer_des_donnees_avec_methode_get'></a>

## Méthode `get` pour une donnée unique

On peut utiliser la méthode `get` sur la table pour récupérer une donnée unique.

À la grande différence de la méthode `select` vue précédemment, la méthode `get` retourne seulement le hash des données de la rangée recherchée.

    data_row = ma_table.get 12
    # data_row est un Hash contenant les données.

On peut spécifier les colonnes à recevoir dans un second argument :

    hash_data = ma_table.get <id>, [<liste colonnes>]

Par exemple :

    data_row = ma_table.get 12, [:id, :nom, :prenom]
    # data_row ne contiendra que :id, :nom et :prenom

Le premier argument de `get` peut être également la définition d'une clause WHERE, définie par string ou par Hash :

    drow = table.get( id: 12 )

Bien sûr, ça n'est pas intéressant ici avec l'`:id` mais ça peut l'être avec toute autre valeur :

    pseudo = table.get(mail: user_mail)[:pseudo]

    OU

    pseudo = table.get({mail: mail_user}, [:pseudo])[:pseudo]

    OU

    pseudo = table.get({mail: mail_user}, :pseudo)

    OU

    pseudo = table.get(where: "mail= '#{mail_user}'", :pseudo)

La dernière utilisation montre l'usage d'un second argument avec une valeur symabolique et non pas un Array : il renvoie seulement la valeur de cette colonne, pas un Hash.

Récapitulatif :

    Premier
    argument
    --------

     Fixnum           Recherche par ID

     Hash/String      Recherche par condition WHERE

     Second
     argument
     ---------

     Inexistant       Retourne toutes les clés de la donnée spécifiée par le
                      premier argument.
     Array            Retourne un Hash contenant les clés contenus dans
                      le Array.
     Symbol           Retourne seulement la valeur de cette colonne.

<a name='modification_des_donness'></a>

##Modification des données (UPDATE/SET)

### Par `set`

Trois syntaxe possibles :

    # Formule privilégiée
    table.set values: {<hash valeurs à modifier>}, where: {<hash condition>}

    # NOTER QUE LA CLAUSE WHERE, ICI, DOIT OBLIGATOIREMENT ETRE DÉFINIE
    # PAR UN HASH SI ELLE NE SE FAIT PAS PAR "ID = " (afin de pouvoir ajouter
    # la valeur si la donnée n'existe pas encore)
    # On a le cas par exemple sur l'atelier avec le texte des actualités :
    # table_textes.set(values: {content: "La liste HTML"}, where: {name: 'actualites_html'})
    # Le texte des actualités est récupéré par `name` pas par ID. À la toute première
    # création du texte, quand il n'existe pas, il faut ajouter aux values la valeur
    # de :name : values: {content: "La liste HTML", name: 'actualites_html'}
    # Donc il faut définir la clause WHERE par un hash.

    table.set <id donnée>, <hash de données>

    table.set(id: <id donnée>, col1: <value 1>.... colN: <value N>)

    table.set( <id donnée> => {<hash de données>} )


Noter que l'utilisation de `set` permet aussi de créer une donnée puisqu'un test d'existence est fait par la méthode.

###Par `udpate`

Syntaxe :

    table.update <id donnée>, {<hash des nouvelles données>}

Noter que cette méthode ne permet pas de créer la donnée, il s'agit vraiment d'un actualisation.

<a name='destruction_dune_donnee'></a>

##Destruction d'une donnée (DELETE)

Syntaxes possibles&nbsp;:

    table.delete <id donnee>
    # => Détruit la donnée d'id <id donnee>

    table.delete condition: "<condition>"
    # => Détruit les données qui répondent à la condition


<a name='destruction_de_toutes_les_donnees'></a>

##Destruction de toutes les données (`pour_away`)

@syntaxe

    table.pour_away

Ce code supprime toutes les rangées de la table, mais sans détruire la table pour autant.

<a name='retourner_le_nombre_de_rangees'></a>

##Retourner le nombre de rangées (count)

Nombre total de rangées&nbsp;:

    nombre_rangees = table.count

Nombre de rangées répondant à une condition&nbsp;:

    nb = table.count condition: "<la condition WHERE>"

    OU

    nb = table.count where: "<la condition WHERE>"

Par exemple&nbsp;:

    nb = table.count where: "mot LIKE \"%ça%\""


---------------------------------------------------------------------

<a name='appel_direct_de_fonction_bdd'></a>

##Appels directs de méthodes `BdD`



<a name='relever_valeurs_avec_execute'></a>

###Relever des valeurs avec `BdD::execute`

@syntaxe rapide&nbsp;:

    require 'sqlite3'

    params = {
      database:     ma_base_de_donnees,   # {SQLite3::Database}
      table:        "ma_table",
      request:      "select",
      colonnes:     [:id, :created_at, :user_id],
      where:        "updated_at > ?",   # Clause Where avec '?'
      offset:       10,                 # Commencer à la 10e rangée
      limit:        5,                  # Ne retourner que 5 rangées
      values:       ["2521236988"]      # Valeurs pour les ?
    }
    resultat = BdD::execute params

`resultat` sera un `Hash` qui contiendra en clé l'identifiant de la rangée (toutes les rangées des tables de BdD contiennent un identifiant, même lorsqu'il n'est pas défini dans le schéma) et en valeur un Hash définissant les valeurs :

    resultat = {
      <row id> => {
        id:           <row id>,
        created_at:   <row created at>,
        user_id:      <row user id>
      }
    }

La relève commencera à la 10e rangée (offset = 10), seuls 5 rangées seront retournées (limit = 5) et seuls les rangées qui ont été actualisées (updated_at > ?) après le 23 novembre 2049 (values = ["2521236988"]) seront retournées.

Noter que toutes les valeurs `String` sont estimées, par exemple les `"NULL"` sont transformés en `nil` ruby.

<a name='bdd_execute_explication_arguments'></a>

###Arguments passés à `BdD::execute`

L'argument unique passé à `BdD::execute` doit être un {Hash} contenant&nbsp;:

    database:   {SQLite3::Database|BdD} La database
    table:      {String} Nom de la table
    colonnes:
    columns:    {Array de Symbols} Liste des clé/colonnes à prendre
                Obligatoire pour le moment. Et ne peut pas être "*"
                Si ce n'est pas une valeur Array, on considère que c'est
                une clé seule et on la met dans un Array qu'on passe à
                la variable.
    do:
    requete:
    request:
    operation:  Opération à exécuter (SELECT, UPDATE, INSERT INTO etc.)
    values:     {Hash ou Array} Les valeurs.
                C'est soit un Array, une liste des valeurs, soit un Hash
                ou la clé correspond à la colonne.
                Si c'est un Array, des '?' doivent être utilisés dans les
                clause. Si c'est un Hash, ce sont les clés elles-mêmes
                qui doivent être utilisées.
    OPTIONNEL
    ---------
    where:        Clause WHERE. Soit en "cle = valeur", soit, mieux, en
                  "cle = ?" et la définition de where_value ou where_values
    where_value   {Any} Si la clause WHERE n'utilise qu'un seul '?'
    where_values  {Array} Si la clause WHERE utilise plusieurs "?", il faut
                  les définir ici dans un Array
    order:
    order_by:     {String|Array} Nom de la colonne pour faire le tri ou des
                  colonnes.
    reverse:      {Boolean} True s'il faut inverser. Attention, si plusieurs
                  colonnes sont précisées dans ordre_by, le DESC ne sera
                  "posé" que sur la dernière. Si on doit inverser d'autres
                  colonnes, le faire explicitement dans `order_by', par
                  exemple : params[:order] = "nom DESC, prenom, age DESC"
                  Dans ce cas, inutile de mettre reverse: à true.
    limit:        {Fixnum|String} Nombre limite
    offset:       {Fixnum|String} Décalage du premier enregistrement testé



---------------------------------------------------------------------


<a name='modules_de_methode_dinstance_de_classe'></a>

##Module de méthodes d'instance d'objet

Ce module est défini dans `./ruby/lib/class/BdD/Modules/module_objet_bdd.rb`.

Il est chargé automatiquement puisqu'il se trouve dans le dossier `lib/class` qui est toujours chargé.
MAIS : Il faut le charger avant le reste, car App, par exemple, en a besoin.

<a name='modules_de_methodes_dinstance_acquisition'></a>

###Acquisition des méthodes (`include`)

Puisque le module est toujours chargé, il suffit d'ajouter&nbsp;:

    class MaClasseBDD

        include MethodesObjetsBdD # <===


<a name='modules_de_methodes_dinstance_requis'></a>

###Méthodes et propriétés requises

Pour pouvoir fonctionner, les méthodes d'instance ont besoin de&nbsp;:

    `table`

        Propriété-méthode qui retourne l'objet BdD::Table de la table où
        sont consignées les données.


<a name='module_methodes_objet_methode_get'></a>

###Méthode `get`

@usage

    <instance>.get <key OU Array of keys>

Retourne la valeur de la clé ou des clés demandées. Retourne `nil` si la donnée n'existe pas dans la table.

Noter que **le retour est très différent suivant l'argument passé**&nbsp;:

* Lorsque l'argument est une clé unique (par exemple `instance.get(:ma_cle)`), la méthode retourne **seulement la valeur** de cette clé dans la base.
* Lorsque l'argument est une liste de clés (par exemple `instance.get([:ma_cle, :autre_cle])`) alors **la méthode retourne un `Hash`** avec en clé les clés demandées (+ la clé :id même si elle n'est pas demandée) et en valeur les valeurs dans la table.

<a name='module_methodes_objet_methode_save'></a>

###Méthode `save` (alias `set`)

@usage

    <instance>.set  {<hash data>}
    <instance>.save {<hash data>}

Sauve toutes les valeurs de `<hash data>` dans la base de données.


<a name='module_methodes_objet_methode_delete'></a>

###Méthode `delete` (alias `remove`)

@usage

    <instance>.delete
    <instance>.remove

Détruit dans la table la rangée de l'instance courante.

<a name='module_methodes_objet_methode_data'></a>

###Méthode `data`

@usage

    hdata = <instance>.data

Retourne toutes les données enregistrées dans la table de l'instance, ou un `Hash` vide si l'ID est NIL ou enfin retourne NIL si la donnée n'existe pas.

---------------------------------------------------------------------

<a name='annexes'></a>

## Annexes


<a name='notes_de_programme'></a>

### Notes de programme

**N0001**

Quand le premier argument de la méthode `set` est un hash, il contient souvent `:values` pour indiquer les valeurs à enregistrer et `:where` pour définir quelle rangée prendre. Lorsque c'est le cas, et que c'est une création, il faut obligatoirement que `where` définisse un `Hash` et pas un `String` (par exemple `where: {name: "name"}` au lieu de `where: "name = 'name'"`) car les propriétés de cette clause where devront certainement être ajoutées aux values (pour ne pas répéter).

Par exemple, si on a la tournure :

    ma_table.set(where: {id: 12}, values: {nom: "Son nom", prenom: "Son prénom"})

Au final, si c'est une création (la donnée #12 n'existe pas encore), il faudra obtenir :

    values: { nom: "Son nom", prenom: "Son prénom", id: 12 }

Donc il faut obligatoirement que `:where` soit un `Hash` pour pouvoir l'ajouter aux values.


<a name='debuggagedesrequetes'></a>

### Débuggage des requêtes

On peut obtenir un affichage des requêtes dans le débug du programme en utilisant :

    BdD::debug_start

    ... les requêtes sont affichées dans le débug ...

    BdD::debug_stop

    ... Les requêtes ne sont plus affichées dans le débug ...
