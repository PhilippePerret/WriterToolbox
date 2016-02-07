# Works / Travaux

* [Présentation générale](#presentationgenerale)
* [Statut (`status`) des travaux (work)](#statutdutravail)
* [Valeur des bits d'options](#valeursbitsoptions)

<!-- -------------------------------------------------------------- -->

<a name='presentationgenerale'></a>

## Présentation générale

Les données `Unan::Program::Work`(s) sont des objets très importants puisque ce sont eux qui consignent l'état d'un travail.

Deux données permettent de surveiller cet état :

* **status**. Un nombre de 0 à 9 pour suivre l'état comme dans les autres données (cf. [Statut des travaux](#statutdutravail)).
* **options**. Une valeur de 64 chiffres de 0 à 9 qui permettent un suivi très serré du travail, avec la consignation des mails de rappel, etc. cf. [Valeur des bits d'options](#valeursbitsoptions).


<a name='statutdutravail'></a>

## Statut (`status`) des travaux (work)

Le statut est une valeur de 0 à 9 contenue dans la propriété `statuts` du travail (instance `Unan::Program::Work`).

Ce statut est passé à 9 lorsque le travail est achevé, de force ou réellement. C'est lorsqu'il est à 9 qu'il sort des listes de variables qui contiennent les IDs des travaux, à commencer par `:works_ids` (contenant tous les IDs des travaux du programme).

Valeurs :

    0   Travail créé/instancié

    9   Travail terminé

<a name='valeursbitsoptions'></a>

## Valeur des bits d'options

Pour le moment, les bits d'options d'un `Unan::Program::Work` ne sont pas utilisés.
