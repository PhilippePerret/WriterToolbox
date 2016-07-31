# Base MySQL

* [Exécution d'une requête simple dans une table](#executiondunerequetesurunetable)
  * [Méthode `get`](#methodeget)
* [Exécution d'une requête complexe dans une base](#executerunerequetecomplexedansbase)
* [MySQL en ligne de commande](#mysqlenlignedecommande)

<a name='executiondunerequetesurunetable'></a>

## Exécution d'une requête simple dans une table

@résumé

    site.dbm_table(<suffix base>, <nom table>[, <online>]).<requete>(<options>)

<a name='methodeget'></a>

### Méthode `get`

    tbl = site.dbm_table(:base, '<table>')

    tbl.get(<who>[, <{options}])
    # => Hash des données

`who` peut être :

    De la meilleure valeur à la moins bonne

    id    L'identifiant Fixnum
    {where: 'prop = ?'}   avec en options values: [<la valeur>]
    {where: {prop: valeur}}

Exemples :

    tbl = site.dbm_table(:base, '<table>')
    tbl.get(12)
    # => Retourne le HASH de la rangée #12

    tbl.get({where: 'created_at > ?'}, {values: [NOW - 3600]})
    # => Retourne le hash créé dans l'heure précédente
    # Noter les deux hash indispensables :
    # get( {}, {} )

    tbl.get({where: {id: 12}}, {colonnes: []})
    # => Hash ne contenant que :id => 12

<a name='executerunerequetecomplexedansbase'></a>

## Exécution d'une requête complexe dans une base

@résumé

    site.db_execute(<prefixe base>, <requête sql>[, <options>])

@exemple

    site.db_execute(:forum, 'SHOW TABLES')
    # => Array de hash contenant chacun une table

    site.db_execute(:forum, 'SELECT * FROM posts WHERE created_at > ?', {values: [NOW - 3600]})
    # => Liste des posts ayant été créés dans l'heure passée.

`prefixe base` est la fin du nom de la base, après le `boite-a-outils_`. Au jour d'aujourd'hui on peut trouver :

    hot           Par exemple pour les users, les connexions, etc.
    cold          Par exemple pour les citations, les tweets permanents
    cnarration    Toutes les tables pour la collection narration
    biblio        Pour le filmodico et le scénodico
    unan          Pour le programme UN AN
    forum         Pour le forum

`requête`

Une requête SQL conforme. Elle peut ne pas se terminer par un ';', il sera toujours ajouté.

`options`

Peut permettre plusieurs choses :

    :symbolize_names    
        (true par défaut) Mettre à faux pour que les
        clés des résultats ne soient pas symbolisés

    :values
        Une liste de valeurs pour remplacer les "?" dans la
        requête. Elles sont appelées les "valeurs préparées"

    :online
        True      => On force l'exécution online, même si l'on est offline
        False     => On force l'exécution offline, même si online
        NilClass  => On exécute la requête là où on se trouve


<a name='mysqlenlignedecommande'></a>

## MySQL en ligne de commande

    > mysql -u root -p
    => Demande le mot de passe
       Taper le mot de passe défini dans ./data/secret/mysql.rb

* [Interrompre l'énoncé d'une requête](#interrompreennoncerequete)
<a name='interrompreennoncerequete'></a>

## Interrompre l'énoncé d'une requête

Utiliser `\c`.

Détail : quand on fait une requête, on passe à la ligne tant que `;` n'est pas détecté :

    mysql> SELECT
        -> *
        ->

Si on s'est trompé et qu'on veut interrompre les `->` on utilise ce `\c`.
