# La collecte {#la-collecte}

## Fichier principal de la collecte {#main-file-collecte}

Le **fichier principal de collecte** est le fichier duquel est tiré l'analyse complète du film. Il contient presque toutes les informations sur le film.

Ce *fichier principal de collecte* est un fichier normalisé qui permet de relever très vite les informations des films. Ce *très vite* est bien entendu très relatif, sachant qu'on ne peut pas aller plus vite que le film lui-même sans l'avoir vu au moins deux ou trois fois.

De façon globale, ce fichier est constitué d'une première partie, l'entête, qui contient les informations générales sur le film (titre, réalisateur, année, etc.) et la seconde partie, la plus longue, contient le détail de tous les éléments, insérés dans des scènes.

Voici un petit aperçu de ce fichier :

    #!TMFILM

    TITRE:  The Maze Runner
    ANNEE:  2014
    ID:     TheMazeRunner2014
    REAL:   Wes Ball
    PITCH:
    FIN:    1:46:15

    OPTION: SUBFOLDER

    SCENE:0:00:20
      RESUME: Arrivée de [PERSO#Thomas] au “bloc”.
      SYNOPSIS: [PERSO#Thomas] se réveille, comme sortant de l'eau, dans un ascenseur en pleine… ascension. Il est accueilli par une bande de jeune et son chef XXX. [PERSO#Thomas] ne se souvient de rien, comme les autres avant lui.
      KEYFONCTION: Incident déclencheur
      CARPERSO#Thomas: Il a peur, il appelle au secours.
      CARPERSO#Thomas: Il court, s'enfuit en sortant de l'ascenseur.

    SCENE:0:05:00
      RESUME:   L'explication de ce monde par [PERSO#Alby], découverte des lieux. Les règles.
      FONCTION: Fonction de la scène
      SYNOPSIS: Synopsis
      EVENT#1: 0:05:35 [PERSO#Thomas] fait la connaissance de [PERSO#Newt].
      EVENT#2: 0:07:20 [PERSO#Thomas] fait la connaissance de [PERSO#Chuck]. Chuck lui a montré comment faire son lit/hamac.
      EVENT#3: 0:08:10 Première découverte des coureurs qui reviennent du labyrinthe ([PERSO#Ben]).
      EVENT#4: 0:08:30 On apprend que c'est un Labyrinthe.

Si vous avez la chance d'être sur Mac et de posséder l'éditeur [TextMate](https://macromates.com), alors cette relève est simplifiée par un *bundle* qui rend la collecte sûre et rapide, comme vous pouvez le constater dans le [tutoriel consacré à la collecte](#tutoriel-collecte).

Pour tout savoir sur le bundle TextMate, <%= manuel_link_to('rediger', 'collecte/tm_bundle', 'consulter l’aide adéquante') %>.

Vous pouvez également utiliser l'<%= lien.collecteur_analyse('éditeur en ligne sur le site') %> qui permet presque d'obtenir le même résultat. Voir <%= manuel_link_to('rediger', 'collecte/en_ligne', 'l’aide de la collecte en ligne') %>.
