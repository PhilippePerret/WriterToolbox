# TODO

# Système de test

L'idée est de pouvoir faire des tests à l'aide de la commande `test`

* par défaut, tous les tests se font OFFLINE

Commande type :

        test <spécification> online|offline

Par exemple :

        test mini online
        # => Lance de test minimume online

        test mon/dossier
        # => Lance les tests se trouvant de spec/mon/dossier/

Pour chaque test "type" => un dossier les contenant ou les chargeant.
