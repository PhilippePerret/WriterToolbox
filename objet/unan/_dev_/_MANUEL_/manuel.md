# Manuel de développement du programme UN AN UN SCRIPT

> Ce manuel en un seul fichier est censé fournir une information rapide sur le développement du programme UN AN UN SCRIPT. Il doit être produit en PDF à chaque changement, et ce PDF doit pouvoir être chargé depuis n'importe quelle grande partie du site.

* [Généralités](#generalitessurleprogramme)
  * [Description du programme](#descriptiongeneraleduprogramme)
  * [Fonctionnement général](#fonctionnementgeneral)
  * [Bureau de l'auteur](#bureaudelauteur)
* [Programme de l'auteur](#programmedelauteur)
  * [Gestion du nombre de points de l'auteur](#nombredepointsdelauteur)
* [Rythme de l'auteur](#rythmedelauteur)
* [Calendrier du programme](#calendrierduprogramme)
* [Les P-Days](#lespdaysduprogramme)
* [P-Days absolus](#lespdayabsolus)
* [Travaux de l'auteur](#travaildelauteur)
  * [L'instance `work`](#instanceworkauteur)
  * [Liste des travaux de l'auteur](#listedestravauxdelauteur)
  * [Class Unan::Program::CurPDay](#laclassecurpday)
  * [Types de travaux](#typesdetravaux)
* [Suivi de l'auteur](#suividelauteur)
  * [Cron toutes les heures](#crontouteslesheures)

<!--
  RACCOURCIS Utiliser [texte][identifiant] ou [identifiant][]
  Ces raccourcis n'apparaitront pas dans le texte final
  Rappel: les IDs sont case-insensitives
  -->
[programme]:  #programmedelauteur       "Le programme de l'auteur"
[rythme]:     #rythmedelauteur          "Le rythme de l'auteur"
[AbsPDay]:    #lespdayabsolus           "Les p-days absolus"
[Points]:     #nombredepointsdelauteur  "Les points du programme"
[work]:       #instanceworkauteur       "Les instances travail"
[liste des travaux de l'auteur] #listedestravauxdelauteur "Liste des travaux de l'auteur"

<a name='generalitessurleprogramme'></a>

## Généralités


<a name='descriptiongeneraleduprogramme'></a>

### Description du programme

Ce programme accompagne un auteur sur une année dans :

* son approche de la narration (aspect pédagogique)
* l'écriture d'un premier scénario ou manuscrit (aspect pratique)

<a name='fonctionnementgeneral'></a>

### Fonctionnement général

Le programme est conçu sur une année, avec des tâches quotidiennes à exécuter par l'auteur. L'auteur travaille en autonomie presque complète, donc ces tâches sont censées lui donner toute information nécessaire pour mener à bien son apprentissage et son récit.

<a name='bureaudelauteur'></a>

### Bureau de l'auteur

Chaque auteur inscrit au programme possède un bureau, son centre de travail névralgique d'où il peut accomplir toutes les actions et voir où il en est de son travail.

---

<a name='programmedelauteur'></a>

## Programme de l'auteur

Tout auteur (user) inscrit au programme UN AN UN SCRIPT possède une instance `Unan::Program` consignée dans la table `programs` de `unan_hot.db`.

<a name='nombredepointsdelauteur'></a>

### Gestion du nombre de points de l'auteur

Pour encourager l'auteur, un nombre de points lui est accordé chaque fois qu'il achève un travail.

Les points sont conservés dans les [instances `works`][work] du programme. On peut donc obtenir les points d'un travail en particulier par&nbsp;:

        iwork = Unan::Program::Work::get(program_id, work_id)
        nombre_points = iwork.points

        Ou, si c'est le programme courant de l'auteur :

        nombre_points = user.work(work_id).points


---------------------------------------------------------------------

<a name='rythmedelauteur'></a>

## Rythme de l'auteur

Le rythme auquel on suit le programme UN AN UN SCRIPT est une donnée fondamentale du programme.

Ce rythme a une valeur de **5** quand il est *moyen*, c'est-à-dire qu'un jour-réel correspond à un *jour-programme*.

        RYTHME = 5
        =>  UN JOUR RÉEL = UN JOUR-PROGRAMME

Cette valeur s'obtient par différents moyens&nbsp;:

        user.rythme

        user.program.rythme

---------------------------------------------------------------------


<a name='calendrierduprogramme'></a>

## Calendrier du programme

À chaque programme correspond à calendrier (`Unan::Program::Cal`) propre au programme de l'user qui possède le programme.

On instancie ce calendrier seulement avec l'instance programme&nbsp;:

        program = Unan::Program::new(<prog id>)
        ou
        program = user.program

        calend  = Unan::Program::Cal::new(program)

        ou

        program.cal # TODO: Voir si on peut l'avoir comme ça

Donc pour obtenir le calendrier depuis l'user :

        calendrier = user.program.cal


---------------------------------------------------------------------

<a name='lespdaysduprogramme'></a>

## Les P-Days de l'auteur

Les `P-Days` sont des `jours-programme`. Ils peuvent être réels (correspondre au jour réel) ou non suivant la valeur du [rythme][] du programme.

Quel que soit le [rythme][], il y a toujours 365/366 `p-day` dans une année du [programme][], donc dans le temps du programme.

Les données absolues de ce `p-day` sont définies dans un [`p-day absolu`][AbsPDay] de classe&nbsp;:

        Unan::Program::AbsPDay

<a name='lespdayabsolus'></a>

## P-Days absolus

Les `p-days` absolus, instance de class `Unan::Program::AbsPDay`, définissent précisément le travail à faire ou amorcer un jour précis du calendrier, quel que soit le [rythme][] du programme.

Ces p-days absolus sont définis dans la table&nbsp;:

        unan_cold.absolute_pdays

Ils sont principalement composés de travaux-absolus, les `AbsWorks` :

        Unan::Program::AbsWork

---------------------------------------------------------------------


<a name='travaildelauteur'></a>

## Travaux de l'auteur

<a name='instanceworkauteur'></a>

### L'instance `work`

* [L'instance `Unan::Program::Work`](#linstancework)
* [Obtenir l'instance `Work`](#obtenirlinstancework)
* [Propriétés de l'instance `Unan::Program::Work`](#proprietesdework)
* [Suivi du travail](#suividutravaildelauteur)
* [Programmation future d'un `work`](#programmationfuturedunwork)

<a name='linstancework'></a>

#### L'instance `Unan::Program::Work`


Les travaux de l'auteur sont des instances&nbsp;:

        Unan::Program::Work

Ils sont consignés dans la table&nbsp;:

        DATABASE
          ./database/data/unan/user/<user-id>/programme<program-id>.db
        TABLE
          works

Noter un point important : ces “works”, la plupart du temps, ne sont créés que lorsque le travail est marqué démarré par l'auteur. Plus précisément, pour créer le work, il faut que :

* une “tâche” doit être marquée “démarrée” par l'auteur,
* une “page de cours” doit être marquée "vue" par l'auteur,
* un “quiz” soit rempli par l'auteur,
* (les choses ne sont pas encore définis pour les messages de forum).

<a name='obtenirlinstancework'></a>

#### Obtenir l'instance `Work`


Pour obtenir une instance d'un travail en particulier et donc lire ses données ou la manipuler&nbsp;:

        Unan::Program::Work::get(<program>, <work-id>)

        <program> est une instance Unan::Program qu'on peut obtenir par :
        user.program

Si c'est le programme courant de l'auteur, on peut l'obtenir par&nbsp;:

        user.work(<work-id>)

<a name='proprietesdework'></a>

#### Propriétés de l'instance `Unan::Program::Work`


Cette instance possède ces propriétés :

        id            {Fixnum} Identifiant propre au travail
        program_id    {Fixnum} Identifiant du programme auquel appartient le
                               work
        abs_work_id   {Fixnum} Identifiant du travail absolu correspondant
        indice_pday   {Fixnum} L'indice du jour-programme de ce travail.
                               Noter qu'il correspond au jour-programme du
                               travail absolu, même si le travail a été
                               démarré plus tard.
        type_w        {Fixnum(2)} Type de travail (pour raccourci)
        status        {Fixnum} Statut actuel du travail, de 0 à 9
        options       {String} Options sur 64 octets du travail.
                               Cf. ci-dessous.
        points        {Fixnum} Nombre de points gagnés pour ce travail.
        ended_at      {Fixnum} Timestamp de la fin du travail
        created_at
        updated_at

Pour les points, cf. [Gestion du nombre de points de l'auteur][points].

Pour les particularités de `created_at`, cf. [Programmation dans le futur d'un travail](#programmationfuturedunwork) ci-dessous.

<a name='suividutravaildelauteur'></a>

#### Suivi du travail

Les deux propriétés permettant de suivre un travail sont&nbsp;:

        status        {Fixnum} Nombre de 0 à 9
        options       {String} Chaine de 64 "bits"

Valeurs du status

        0   Travail créé/instancié (inutilisé maintenant que le travail
            est seulement créé lorsque l'auteur le marque démarré/vu)
        1   Travail marqué démarré par l'auteur, c'est-à-dire qu'il l'a
            vu et pris en compte. Il se marque démarré depuis le bureau
            Noter que ça ne s'applique qu'aux "vrais" travaux, pas aux
            pages de cours ou autres quiz.
            Interroger la méthode `started?` pour savoir si le travail a
            été démarré.

        9   Travail terminé
            Interroger la méthode `completed?` pour savoir si le travail
            est fini.

<a name='programmationfuturedunwork'></a>

#### Programmation future d'un `work`

CETTE PARTIE DOIT DEVENIR OBSOLÈTE AVEC LE NOUVEAU FONCTIONNEMENT PAR “RECHERCHE ABSOLUE” (cf. [Liste des travaux de l'auteur](#listedestravauxdelauteur)). MAIS COMMENT LA REMPLACER ?
Un `work` peut être programmé à l'avance. C'est le cas par exemple lorsqu'un questionnaire n'a pas été rempli correctement et qu'il doit être re-proposé plus tard à l'auteur. Dans ce cas, on utilise la propriété `created_at`  et `updated_at` synchronisé pour définir que le travail doit être commencé plus tard.

        iwork.set( created_at: <date dans le future>, updated_at: <date future> )
        # rappel : date est un fixnum correspondant au nombre de secondes


<a name='listedestravauxdelauteur'></a>

### Liste des travaux de l'auteur

NOTE : La liste des travaux ne fonctionne plus par liste d'identifiants consignant les travaux courants de l'auteur. Cela rendait la gestion des changements de jours infornale.

Maintenant, on consulte simplement les travaux à faire dans l'absolu de cette façon :

        Soit le jour-programme courant PD
        * On relève tous les travaux absolus de tout type à faire jusqu'à
          ce PD (ce qui peut être très "long" vers la fin, mais il n'y
          aura que 366 jours de toute façon)
        * On relève tous les travaux finis et non finis de l'auteur
          (donc ses "works")
        * On retire de la liste des travaux absolus tous les travaux
          qui ont été achevés par l'auteur.
        * Il ne reste alors dans la liste des travaux absolus que les
          travaux courants, dont certains peuvent avoir été démarrés
          (un "work" auteur existe, alors) et d'autres non démarrés (dans
          ce cas, ils ne possèdent pas de "work" auteur)

<a name='laclassecurpday'></a>

## Class Unan::Program::CurPDay

Une classe est spécialement dédiée à la gestion des travaux au jour courant :

        Unan::Program::CurPDay

Dans le bureau central de l'auteur, on peut obtenir l'instance de cette classe par :

        bureau.current_pday

Pour obtenir les travaux non achevés de type `task` :

        bureau.current_pday.undone(:task)
        # => {Array} de {Hash} contenant les données des
        # travaux absolus + les données du work si le travail
        # a été démarré

Les trois méthodes principales sont :

        done(type)        # Liste des data de travaux accomplis
        undone(type)      # Liste des data de travaux inachevés
        encours(type)     # idem
        started(type)     # Liste des data de travaux démarrés
                          # mais non achevés

<a name='typesdetravaux'></a>

### Types de travaux

L'auteur peut avoir ces types de travaux :

* fiche de cours à lire,
* travail à faire (un document, une recherche, etc.),
* questionnaire à remplir,
* réponse ou message à passer sur le forum.

        WORKS désigne n'importe lequel de ces travaux dans le programme.

        Les types, au niveau du programme, sont :

            TASK      Une tâche à accomplir
            QUIZ      Un questionnaire à répondre
            PAGE      Une page de cours (Narration) à lire.
                      Noter qu'il ne s'agit pas de l'id de la page dans
                      Narration mais d'un identifiant propre à Unan,
                      puisqu'il s'agit ici d'un work.

Pour le détail sur les listes de travaux, cf. la [liste des travaux de l'auteur][].

Un work s'instancie à l'aide de :

        Unan::Program::Work::new(<user>.program, <work id>)
        # (ou get)

        L'instance Work possède une propriété `item_id` qui définit
        l'ID de l'item en fonction du type de work :

            Si le type est          Alors item_id est
            ------------------------------------------------------------
            task                    l'ID d'une tâche
            quiz                    l'ID d'un questionnaire
            page                    l'ID d'une page de cours
            forum                   l'ID d'un travail de forum



<a name='suividelauteur'></a>

## Suivi de l'auteur

<a name='crontouteslesheures'></a>

### Cron toutes les heures

Toutes les heures, un `cron-job` est lancé, conséquent, qui permet de contrôler les auteurs et, principalement, de :

* leur envoyer les nouveaux travaux,
* leur signaler tout retard,
* les encourager à poursuivre,
* leur accorder des bonus en cas de bon comportement.
