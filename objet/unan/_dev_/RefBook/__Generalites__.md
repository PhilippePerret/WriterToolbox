# Généralités sur le programme “Un An Un Script”

* [Hiérarchie des éléments dans le programme](#hierarchiedeselements)
* [Les “jours-programme”](#lesjoursprogrammes)

<a name='hierarchiedeselements'></a>

## Hiérarchie des éléments dans le programme

    Unan        Classe principale gérant tout le reste. C'est en quelque sorte
                l'espace de nom

    Program     Le programme lui-même. Chaque auteur possède une instance de
                cette classe (Unan::Program).

    Cal         Le calendrier. Il contient tous les jours du programme
                et tient
                compte du rythme pour connaitre le nombre de jours réels possède
                le programme.

    Day         Un jour réel du calendrier

    ------------------------------------------------------------------------------
    Unan
    Program
    PDay        Un "jour-programme", c'est-à-dire un vrai jour de
                programme sans
                tenir compte du rythme. Un jour-programme vaut un jour réel lorsque
                le rythme est de 5, c'est-à-dire le rythme moyen/normal.
                Il s'agit ici de l'instance pour l'auteur, qui définit comment
                s'est déroulé un p-day du programme pour l'auteur.

    Work        Un travail de l'auteur.

    Unan
    Program
    AbsPDay     Définition absolue d'un "jour-programme"
    AbsWork     Définition absolue d'un travail particulier.



Il faut au maximum que ce programme soit **ludique**. Par les vecteurs suivant :

* L'interactivité
* Les questionnaires stimulants
* Un système de comptage de points motivants

Définition très clair du travail, annoncé "la veille" par un texte comme "La prochaine fois, vous devrez travailler sur…".

<a name='lesjoursprogrammes'></a>

### Les “jours-programme”

Le “jour-programme” est l'unité de temps de base pour un programme complet. En rythme normal (= 5), un jour réel correspond à un jour-programme.

Un jour-programme définit un travail bien précis, pour chaque jour d'écriture. En réalité, on pourrait dire plutôt que chaque “semaine-programme” (donc 7 jours-programme) définissent un travail particulier, car il n'y a jamais de travail à exécuter seulement en un jour-programme donné, même si ce jour-programme dure 3 jours normaux (rythme très lent).
