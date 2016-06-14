# Passage de SQLite3 à MYSQL

> NOTE : Ce fichier doit servir aussi de mode d'emploi. Il sera glissé dans le dossier d'aide.

* [Principe généraux](#principesgeneraux)

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
