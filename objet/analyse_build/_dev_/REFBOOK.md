# Manuel de référence de analyse_build

* [Introduction](#introduction)
* [Données du film](#donneesdufilm)
* [Données des scènes collectées](#donneesdesscenes)
* [Données des brins](#donneesdesbrins)

## Introduction {#introduction}


Cette section permet aux analystes et administrateurs de gérer les analyses au niveau des dépôts, des relectures, des commentaires, etc.

## Données du film {#donneesdufilm}

Les données du film sont enregistrées dans le fichier `FILM.msh` qui est créé dès qu'on l'a trouvé (son ID filmodico doit être fourni pour que le dépôt soit effectué).

Ce fichier marshal contient un `Hash` contenant :

    id          ID filmodico du film
    titre       Le titre du film, pour ne pas avoir à faire sa
                fiche.
    duree       {Fixnum} Durée en secondes du film. Mais seulement
                si le fichier de collecte de scènes se termine par :
                x:xx:xx ->| FIN
                Note : mais c'est de toute façon la durée dans la
                fiche qui sera prise en compte.
    created_at  La date du dépôt
    updated_at  La date de modification du dépôt. Pas vraiment
                utile pour les données du film, qui n'ont pas à
                être modifiées.

## Données des scènes collectées {#donneesdesscenes}

Les données des scènes collectées se trouve dans le fichier `SCENES.msh`.

Données enregistrées :

    numero        Numéro de la scène
                  C'est l'identifiant de la scène.
    resume        Le résumé string, défini sur la première ligne
                  d'info
    effet         L'effet JOUR, NUIT, MATIN, SOIR, ou NOIR
    lieu          EXT. ou INT.
    decor         Le décor exact.
    time          Le temps de la scène, en commençant à 0.
    horloge       L'horloge de la scène, en commençant à 0:00:00.
    notes         Les notes de la scène, telles qu'elles sont
                  entrées dans le fichier de collecte.
    paragraphes   La liste des paragraphes.
                  C'est un {Array} qui contient des {Hash}
                  définissant chaque paragraphe, s'il existe (la
                  scène peut ne pas avoir de paragraphes
                  lorsqu'elle possède seulement un résumé).


## Données des brins {#donneesdesbrins}

Les données des brins d'une collecte sont enregistrées et développées dans le fichier `BRINS.msh`.

Les données enregistrées :

    id                                {Fixnum} ID absolu du brin

          C'est celui qui est défini dans le fichier de collecte des
          brins.

    titre                                 {String} Titre du brin

          La première ligne sous l'ID dans le fichier de collecte
          des brins.

    para_or_scene_ids     {Array} Identifiants des paras ou scènes

          Liste des identifiants de paragraphes ou de scène qui
          appartiennent au brin.
          Rappel : les identifiants de scène sont des {Fixnum} qui
          correspondent au numéro de la scène. Les identifiants de
          paragraphes sont des strings composés de "<scene>:<id
          absolu>"
          Cette liste est déterminée lors du développement des data.
