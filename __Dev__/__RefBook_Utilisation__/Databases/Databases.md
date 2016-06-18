# Bases de données

* [Introduction](#introductionbasededonnees)
* [Récupérer n'importe quelle table (ou la créer)](#getanytableorcreate)
* [Exemple complet d'utilisation dans le programme](#exemplecompletdutilisation)
* [Définition d'une table](#definitiondunetable)
  * [Définition du schéma de la table](#definitionduschemadelatable)
  * [Définition des colonnes d'une table](#colonnedefinitiondunetable)
* [Méthodes courantes pour les objets BdD](#methodesdesobjetsbdd)



<a name='introductionbasededonnees'></a>

## Introduction

Les applications RestSite 2.0 fonctionnent à base de database SQLite3.

Ces bases de données doivent être définies dans le dossier :

    ./database/table_definitions/

Les données de ces tables se trouvent dans :

    ./database/data/

*Note : C'est ce dossier qui doit être utilisé pour les gels.*


<a name='getanytableorcreate'></a>

## Récupérer n'importe quelle table (ou la créer)

Pour récupérer n'importe quelle table de base de données dans le programme, qu'elle soit ou non créée, on utilise la tournure :

    site.dbm_table(:<ref base>, '<nom table>')

Il est juste nécessaire que le schéma de la table soit défini tel qu'attendu. Cf. [Définition d'une table](#definitionduschemadelatable)

<a name='exemplecompletdutilisation'></a>

## Exemple complet d'utilisation dans le programme

On a besoin d'une table dans le programme. Pour l'exemple, on va dire qu'on a besoin d'une base `bibliotheque` qui contient les tables `livres` et `auteurs`.

On définit dans le fichier `./database/tables_definition/db_bibliotheque/table_livres.rb` le schéma de la table des livres (cf. [Définition du schéma de la table](#definitionduschemadelatable))

On définit dans le fichier `table_auteurs.rb` dans le même dossier la table des auteurs.

On va créer un objet `Bibliotheque` :

    Dossier ./objet/bibliotheque/

On fait un fichier database.rb (le nom est indifférent) dans lequel on va écrire :

    class Bibliotheque
      class << self
        def table_livres
          @table_livres ||= begin
            site.dbm_table(:biblio, 'livres')
          end
        end
      end
    end

On a juste besoin de cette ligne pour récupérer n'importe quelle table.

Ensuite, si je veux créer un livre, je peux mettre quelque part :

    def creer_un_livre titre
      data_livre = {titre: titre}
      id_nouveau_livre = Bibliotheque::table_livres.insert(data_livre)
    end

<a name='definitiondunetable'></a>

## Définition d'une table

<a name='definitionduschemadelatable'></a>

### Définition du schéma de la table


Si la base de données s'appelle `nomdb`, on doit trouver un dossier :

    ./database/table_definitions/db_nomdb/

Si la table à l'intérieur de cette base s'appelle `tabledb`, alors son schéma doit être définie dans le fichier :

    ./database/table_definitions/db_nom/table_tabledb.rb # ruby

Dans ce fichier, on doit trouver seulement définie la méthode :

    schema_table_nomdb_table_db

De cette manière :

    ### Dans ./database/table_definitions/db_nom/table_tabledb.rb

    # encoding: UTF-8
    def schema_table_nomdb_table_db
      @schema_table_nomdb_tabledb ||= {
        ... définition ... cf. ci-dessous
      }
    end

<a name='colonnedefinitiondunetable'></a>

### Définition des colonnes d'une table

On trouve en clé le nom ({Symbol}) de la colonne. Par exemple :

    :id

On trouve en valeur un `Hash` définissant la colonne :

    type:         Le type             VARCHAR(32)
    constraint:   La contrainte       NOT NULL ou PRIMARY KEY AUTOINCREMENT
    default:      La valeur défaut

<a name='methodesdesobjetsbdd'></a>

## Méthodes à inclure pour les objets BdD

J'appelle "objets BdD" tous les objets, donc toutes les instances, qui sont créées pour des éléments enregistrées dans des bases de données `BdD`.

On inclut ces méthodes en ajoutant la ligne :

    include MethodesObjetsBdD

… au-dessus de la classe.

Pour utiliser ces méthodes, il faut impérativement définir la méthode d'instance `table` qui renvoie la table `BdD::Table` contenant l'objet (les données de l'instance).

    def table
      @table ||= <BdD::Table contenant les données>
    end

Ensuite, on peut utiliser les méthodes :

    #data       Retourne toutes les données
    #get(key)   Retourne la valeur de la clé `key` ou du hash de données
                si c'est un hash qui est transmis
    #set(hash_key)    Enregistre le hash de données hash_key
                      Noter que les variables d'instance courantes seront aussi
                      modifiées
    #save(hkey)       Cf. #set
    #delete     Détruit la donnée dans la base de donnée
    #remove     Cf. #delete

### Méthode spéciale `get_all`

Pour ne pas multiplier les appels à la base de données, on peut charger toutes les données d'un objet d'un seul coup, à l'aide de la méthode `get_all` :

    mon_objet = ObjetBD::new
    mon_objet.get_all # => charge toutes les données
    mon_objet.duree
    # duree étant une propriété et une méthode utilisant get(:duree),
    # la méthode get_all a mis :duree dans @data avec sa valeur et
    # la méthode get cherchera d'abord dans @data[:duree] pour retourner
    # la valeur

Noter que `get_all` a l'avantage de remettre à nil `@data`, même si des méthodes get ont été appelées avant (initialisant `@data`), ce qui force dans tous les cas la lecture de la donnée dans la base de données.
