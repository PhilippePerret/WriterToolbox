## Explication du fonctionnement de la collection Narration

* [Bases de données de la collection](#basededonneesdelacollection)
  * [Table des pages](#tabledespages)
  * [Table des table of content des livres](#tabledestablesdesmatieres)


Pour le moment, les fichiers originaux de la collection Narration se trouve dans le programme UN AN :

    ./data/unan/pages_cours/cnarration/

Ce sont des fichier `Markdown` qui vont suivre ce processus de traitement :

    MARKDOWN  >  ERB  >  HTML

Les fichiers ERB sont fabriqués dans le dossier :

    ./data/unan/pages_semidyn/cnarration/

Ce sont des fichiers qui peuvent être chargés “as-is” avec des balises ERB interprétées à la volée, permettant de sexuer la page ou de déterminer des noms en temps réels comme des dates, etc.

<a name='basededonneesdelacollection'></a>

### Bases de données de la collection

La collection narration est consignée dans la base de données :

    ./database/data/cnarration.db

Cette base contient deux tables :

    pages         Données pour les pages et les titres
    tdms          Données pour les tables des matières

<a name='tabledespages'></a>

#### Table des pages

La table des pages `pages` contient les données pour :

    Les chapitres
    Les sous-chapitres
    Les pages

La distinction se fait au niveau du premier octect de la donnée `options` :

    1     Une page
    3     Un sous-chapitre
    5     Un chapitre

Noter que dans la consultation les titres produisent eux aussi des pages, ce qui donne vraiment l'apparence d'un livre.

<a name='tabledestablesdesmatieres'></a>

#### Table des table of content des livres

La table des “table of content” des livres contient simplement l'ID du livre (de 1 à x) et la donnée `tdm` qui est une liste `Array` des identifiants de titres et de pages dans l'ordre.
