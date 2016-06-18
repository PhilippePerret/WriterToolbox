# Passage de SQLite3 à MYSQL

## MIGRATION -> MYSQL

* Penser à modifier le traitement de l'actualisation de l'accueil
  dans ./objet/site/home.rb

Pour savoir où il y a des choses à corriger, chercher les
balises :


    # -> MYSQL

    # -> MYSQL FORUM
    # -> MYSQL CONNEXIONS
    # -> MYSQL NARRATION

> NOTE : Ce fichier doit servir aussi de mode d'emploi. Il sera glissé dans le dossier d'aide.

* [Principe généraux](#principesgeneraux)
* [Obtenir une instance de table MySQL](#obtenirinstancetablemysql)
* [Nombre de rangées dans une table](#nombrerangeesdanstable)
* [Insertion de rangée dans la table](#insertionderangeesdanslatable)
* [Destruction d'une table](#destructiondunetable)

<a name='principesgeneraux'></a>

## Principe généraux

* [Une base cold, une base hot](#uneuniquebaseforcoldandanohterforhot)
* Le [code de création des tables en dur](#definitiondestablesendur)

<a name='uneuniquebaseforcoldandanohterforhot'></a>

## Une base cold, une base hot

Au lieu de plein de bases de données, on utilise seulement deux bases, une pour les informations cold, celles qui ne bougent pas, comme les données du programme UN AN UN SCRIPT ou les pages narrations. Et une autre hot pour les informations qui sont souvent modifiées, comme les connexions, etc.


<a name='definitiondestablesendur'></a>

## Définition des tables en dur

Au lieu d'un table, mettre le code de création en dur, les commentaires dans le code

Voir l'exemple de la table User

<a name='obtenirinstancetablemysql'></a>

## Obtenir une instance de table MySQL

    site.dbm_table(:hot/:cold, '<nom de la table>')
    # => Instance SiteHtml::DBM_TABLE de la table

<a name='nombrerangeesdanstable'></a>

## Nombre de rangées dans une table

    <dbm_table>.count

Par exemple :

    SiteHTML::DBM_TABLE.new(:hot, 'users').count
    # => nombre d'user enregistrés


<a name='insertionderangeesdanslatable'></a>

## Insertion de rangée dans la table

    <dbm_table>.insert({<data à insérrer>})
    # => Dernier IDentifiant, mais le premier si c'est une
    #    liste de rangées à créer en une seule fois.

Pour obtenir le **NOMBRE DE RANGÉES INSÉRÉES** on peut faire :

    <dbm_table>.nombre_inserted_rows
    # => nombre de rangées insérées


<a name='destructiondunetable'></a>

## Destruction d'une table

Pour détruire complètement une table, utiliser :

    <dbm_table>.destroy

Par exemple :

    site.dbm_table(:cold, 'citation').destroy

ATTENTION : La table est vraiment détruite complètement
