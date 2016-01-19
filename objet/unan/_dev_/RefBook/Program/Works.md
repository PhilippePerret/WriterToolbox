# Works / Travaux

* [Présentation générale](#presentationgenerale)
* [Valeur des bits d'options](#valeursbitsoptions)

<!-- -------------------------------------------------------------- -->

<a name='presentationgenerale'></a>

## Présentation générale

Les données `Unan::Program::Work`(s) sont des objets très importants puisque ce sont eux qui consignent l'état d'un travail.

Deux données permettent de surveiller cet état :

* **status**. Un nombre de 0 à 9 pour suivre l'état comme dans les autres données.
* **options**. Une valeur de 64 chiffres de 0 à 9 qui permettent un suivi très serré du travail, avec la consignation des mails de rappel, etc. cf. [Valeur des bits d'options](#valeursbitsoptions).

<a name='valeursbitsoptions'></a>

## Valeur des bits d'options
