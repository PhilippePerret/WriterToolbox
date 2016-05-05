# Réflexion sur une simplification du programme

Pour simplifier, on pourrait ne rien enregistrer dans les données de l'auteur à part ce qu'il fait. Je m'explique : On en resterait à définir son jour-programme courant (qui serait variable, s'il change plusieurs fois de rythme).

Puis, connaissant son jour-programme, on ferait la liste de ses travaux à faire : on remonterait depuis ce jour-programme jusqu'à un jour-programme où il a encore du travail. Ça correspond à deux choses :
  1. Les jours-programme qui définissent des travaux longs, qui s'étalent
     encore sur le jour-programme courant.
  2. Les travaux qui auraient dû être terminés avant mais qui ne le sont pas

Ensuite, on n'enregistre seulement les travaux exécutés.

On doit aussi enregistrer les questionnaires, ça on ne change rien.

On doit trouver un système pour les travaux reprogrammés. Mais est-ce que ça n'est pas prévisible ? Je veux dire, si un questionnaire doit être reproposé plus tard, ce "plus tard" pourrait être déjà connu, il pourrait déjà être enregistré en tant que work dans un p-day défini.


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
