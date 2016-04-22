# Manuel de développement du programme UN AN UN SCRIPT

> Ce manuel en un seul fichier est censé fournir une information rapide sur le développement du programme UN AN UN SCRIPT. Il doit être produit en PDF à chaque changement, et ce PDF doit pouvoir être chargé depuis n'importe quelle grande partie du site.

* [Généralités](#generalitessurleprogramme)
  * [Description du programme](#descriptiongeneraleduprogramme)
  * [Fonctionnement général](#fonctionnementgeneral)
  * [Bureau de l'auteur](#bureaudelauteur)
* [Programme de l'auteur](#programmedelauteur)
* [Calendrier du programme](#calendrierduprogramme)
* [Travaux de l'auteur](#travaildelauteur)
  * [Types de travaux](#typesdetravaux)
* [Suivi de l'auteur](#suividel'auteur)
  * [Cron toutes les heures](#crontouteslesheures)

<a name='generalitessurleprogramme'></a>

## Généralités


<a name='descriptiongeneraleduprogramme'></a>

### Description du programme

Ce programme est censé accompagner un auteur sur une année dans :

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

Tout auteur (user) inscrit au programme UN AN UN SCRIPT possède une instance `Unan::Program` consignée dans la table `programs` de `unan.db`.

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


<a name='travaildelauteur'></a>

## Travaux de l'auteur


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
            COURS

        Chaque type de travail est consigné dans une "variable-user"
        qu'on peut obtenir et modifier par :
        
            user.set_var(<:nom variable>, <valeur variable>)
            user.get_var(<:nom variable>) # => retourne sa valeur
              
        Ces variables-user porte comme nom :
        
            works_ids       Pour tous les travaux (dont ceux ci-dessous)
            ------------------------------------------------------------
            tasks_ids       Pour les tasks
            pages_ids       Pour les pages de cours à lire
            quiz_ids        Pour les questionnaires à répondre
        
        Les IDs contenus dans ces listes sont des identifiants de :
        
            Unan::Program::Work
        
        Un work s'instancie à l'aide de :
        
            Unan::Program::Work::new(<user>.program, <work id>)
        
        L'instance Work possède une propriété `item_id` qui définit
        l'ID de l'item en fonction du type de work :
        
            Si le type est          Alors item_id est
            ------------------------------------------------------------
            task                    l'ID d'une tâche
            quiz                    l'ID d'un questionnaire
            page                    l'ID d'une page de cours


<a name='suividel'auteur'></a>

## Suivi de l'auteur

<a name='crontouteslesheures'></a>

### Cron toutes les heures

Toutes les heures, un `cron-job` est lancé, conséquent, qui permet de contrôler les auteurs et, principalement, de :

* leur envoyer les nouveaux travaux,
* leur signaler tout retard,
* les encourager à poursuivre,
* leur accorder des bonus en cas de bon comportement.


