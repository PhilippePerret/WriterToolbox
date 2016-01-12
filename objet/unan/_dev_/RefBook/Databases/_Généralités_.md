# Databases :: Généralités

* [Trois types de base de données](#troisbasesdedonnees)

<a name='troisbasesdedonnees'></a>

## Trois types de base de données

Il existe trois types de base de données dans le programme UN AN UN SCRIPT :

1. **unan_cold**. Ce sont les données “froides”, i.e. la définition des travaux, des jours-programmes, etc. Ce sont en quelque sorte des *données fixes*.
2. **unan_hot**. Ce sont les données “chaudes”, i.e. la définition des programmes qui ont déjà eu lieu ou ont lieu, les données sur les projets, etc. Ce sont des données dynamiques qui peuvent être modifiées à tout moment et, surtout, qui concernent les auteurs impliqués dans le programme.
3. **user/program<program ID>.db**. Ce sont les bases de données propre à chaque auteur, qui consigne ses travaux, ses réponses aux questionnaires, etc., i.e. toutes les informations concernant le programme concerné.
