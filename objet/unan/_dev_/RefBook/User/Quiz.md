# Quiz de l'auteur

* [Classe absolue (`Unan::Quiz`) et auteur (`User::UQuiz`)](#classeabsolueetauteur)
* [Requérir la librairie `quiz`](#requirelibrairiequiz)
* [Questionnaires de l'auteur](#chargerlesquizdelauteur)
* [Méthodes d'instance de la classe `User::UQuiz`](#methodesdinstancesuquiz)


<a name='classeabsolueetauteur'></a>

## Classe absolue (`Unan::Quiz`) et auteur (`User::UQuiz`)


Il faut comprendre qu'il y a deux classes pour les quiz :

La classe qui contient les données absolues :

    Unan::Quiz

La classe qui contient les résultats de l'auteur au quiz :

    User::UQuiz

Dans les deux cas, il faut [requérir la librairie `quiz`](#requirelibrairiequiz).

<a name='requirelibrairiequiz'></a>

## Requérir la librairie `quiz`

    site.require_objet 'unan'
    Unan::require_module 'quiz'


<a name='chargerlesquizdelauteur'></a>

## Questionnaires de l'auteur

On peut récupérer les questionnaires de l'auteur à l'aide de la propriété :

    user.quizes
    # => Hash avec en clé l'ID qui UQuiz et en valeur
    # l'instance User::UQuiz.

Cette méthode peut recevoir un filtre pour ne retourner que les instances de quiz voulues.

    user.quizes(
      created_after:
      created_before:
      max_points:            Ne doit pas avoir plus de points que ça
      min_points:            Doit avoir au moins ce nombre de points
      quiz_id:           {Fixnum} ID du questionnaire Unan::Quiz absolu
      )

<a name='methodesdinstancesuquiz'></a>

## Méthodes d'instance de la classe `User::UQuiz`

### `<uquiz>.reponses`

`{Hash}` des réponses données au questionnaire. Avec en clé l'ID de la question et en valeur un Hash contenant :

    qid:        {Fixnum} ID de la question dans la table des questions

    type:       {String(3)} Pour que JS puisse afficher les réponses
    points:     {Fixnum} Total des points marqués
    max:        {Fixnum} Maximum de points qu'il est possible de marquer
                pour cette question.
    value:      {Fixnum|Array de Fixnum} ID de la réponse donnée,  ou liste
                des IDs si c'est une question à réponses multiples.

Instance `Unan::Quiz` du questionnaire de référence.

### `<uquiz>.points`

Le nombre de points marqués à ce questionnaire. Ou nil.

### `<uquiz>.max_points`

`Fixnum`. Le nombre de points maximum qu'on peut gagner à ce questionnaire.

### `<uquiz>.note_sur_vingt`

`Float`. La note sur vingt pour le questionnaire.

> Calculée avec la méthode d'`Array` `sur_vingt` qui prend en premier argument la note totale et en deuxième argument le maximum de moints :

    [points, max_points].sur_vingt(1)

### `<uquiz>.quiz`

Instance `Unan::Quiz` du questionnaire original.
