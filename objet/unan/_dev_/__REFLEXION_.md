# Réflexion sur le fonctionnement des P-Day

- Un P-Day est un jour-programme

Version absolue : abs_pday/AbsPDay
Version auteur  : pday/PDay

Un jour-programme peut être vide s'il n'y a aucun nouveau travail à déclencher.

Sinon, il déclenche des travaux (des abs_work/AbsWork)

Un travail peut être par exemple :
  - la lecture d'une page de cours
  - la lecture d'une page d'aide du programme
  - la rédaction d'un document sur le projet
  - la réponse à un questionnaire
  - un mail à envoyer sur le forum


Donc au déclenchement du jour-programme, on lit simplement tous ses travaux qui vont définir tout ce qu'il y a à faire. Et ce qu'il y a à faire sera dispatché, par commodité, dans des listes d'IDs de l'auteur, par exemple les `task_ids`, les `quiz_ids`, les `pages_cours_ids` etc. qui permettent d'afficher sur le bureau ce que doit faire encore l'auteur.


# Calcul des pdays en fonction du rythme

Comment calculer le prochaine pday d'un auteur ?

À un temps donné, l'auteur a un rythme cR (p.e. 8) et se trouve sur un jour programme cJ (p.e. le 12e). Cela détermine

=> Il faudrait en fait lancer le CRON toutes les heures pour vraiment que les jours-programme suivent le rythme.

coef_rythme = 5.0 / cR # p.e. 
