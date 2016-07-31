# Synopsis du programme ÉCRIRE UN FILM, ÉCRIRE UN ROMAN, EN UN AN

L'idée de ce document est de consigner tout ce qui se passent sur les procédures normales du programme.

## Inscription

Lors de l'inscription sont créés :

    - (si c'est un nouvel user — inscription complète)
      Un enregistrement dans la table <pref>hot.users
    - Un enregistrement dans la table <pref>unan.programs
      (avec auteur_id correspondant à l'user)
    - Un enregistrement dans la table <pref>unan.projet
      (avec auteur_id correspond à l'user et program_id correspondant
       au programme)
    - Un enregistrement dans la table <pref>cold.paiements
      (avec le type '1UN1SCRIPT')
      (C'est cette ligne qui permet de savoir si l'user est
       abonné au programme : il doit être à jour de son paiement)

## Démarrage d'un travail

Lorsque l'auteur rejoint son bureau (son centre de travail), il trouve la liste de ses tâches dans un onglet “Tâches”. Ces tâches sont marqué d'un bouton "Démarrer ce travail" qui permet de démarrer ce travail (pour que l'auteur puisse préciser qu'il a pris en compte ce travail.)

Lorsqu'il clique ce bouton, la route suivante est appelée :

    'work/<id travail>/start?in=unan/program'

Cela appelle le fichier :

    ./objet/unan/program/work/start.rb
