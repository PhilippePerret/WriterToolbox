# Reprise des données

Une fois la première passe faite (dépôt et parse des données), on se retrouve avec des fichiers marshal qui doivent contenir toutes les données. Il faudrait pouvoir les reprendre, pour notamment ajouter et modifier les choses. Pouvoir ajouter des brins, par exemple, est important.

Il faudrait garder l'idée de séparer les données.
- Film. Les données du film (dont l'identifiant, la date de création de la collecte)
-> FILM.msh
- Brins (if any) -> BRINS.msh (données développées)
– Personnages (if any - mais avec possibilité de le créer) -> PERSONNAGES.msh
- Scènes (il faut forcément le donner) -> SCENE.msh


# Dépôt

On fait tout en une seule fois :

1. Dépôt des fichiers
2. Parse des fichiers
3. Construction des fichiers à produire


    L'analyste arrive sur la page home de analyse_build
      • Il trouve un bouton pour déposer des fichiers
      En le cliquant, il rejoint la partie pour déposer ses fichiers
      -> DEPOT_FICHIERS
      • Si des fichiers ont été déposés, il trouve la liste des
      titres de films correspondant à ces fichiers. En cliquant un
      titre il rejoint le traitement des fichiers déposés
      -> TRAITEMENT_FICHIERS
      • Il trouve une partie lui expliquant ce qu'il peut faire ici.




DEPOT_FICHIERS

    analyse_build/depot
    Cette section permet de donner les fichiers d'analyse sur les films,
    afin qu'ils soient parsés/analysés.
    On peut déposer des fichiers :
      - collecte (collecte des scènes et des informations)
      - brins (listing et description des brins)
      - personnages (listing et description des personnages)

    Cette section contient un lien permettant de revenir à tout moment au
    traitement des fichiers (accueil, en fait).


TRAITEMENT_FICHIERS
