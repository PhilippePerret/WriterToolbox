# Base MySQL

* [MySQL en ligne de commande](#mysqlenlignedecommande)


<a name='mysqlenlignedecommande'></a>

## MySQL en ligne de commande

    > mysql -u root -p
    => Demande le mot de passe
       Taper le mot de passe défini dans ./data/secret/mysql.rb

* [Interrompre l'énoncé d'une requête](#interrompreennoncerequete)
<a name='interrompreennoncerequete'></a>

## Interrompre l'énoncé d'une requête

Utiliser `\c`.

Détail : quand on fait une requête, on passe à la ligne tant que `;` n'est pas détecté :

    mysql> SELECT
        -> *
        ->

Si on s'est trompé et qu'on veut interrompre les `->` on utilise ce `\c`.
