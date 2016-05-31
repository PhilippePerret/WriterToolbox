# Sujet des test-méthodes

* [Subject en fonction des test-méthodes](#subjectenfonctiondestestmethodes)

Le “sujet” (`subject`) des test-méthodes permet d'utiliser des méthodes directement en passant par `method_missing`. C'est par exemple par ce biais qu'on peut utiliser toutes les méthodes&nbsp;:

        is_
        has_

… qui correspondent à des méthodes `?`&nbsp;:

        is_unanunscript
        
        utilise
        
        user.unanunscript?

Le `subject` de la test-méthode, qui doit être défini dans son module principal, permet de savoir à qui l'on a affaire.

<a name='subjectenfonctiondestestmethodes'></a>

## Subject en fonction des test-méthodes

    test_user         User          L'utilisateur défini en premier argument
    test_form         Nokogiri      Le formulaire défini en second argument
    test_route        Nokogiri      L'objet `html`, donc la page.
    test_base         BdD::Table    Une table de base de données.
    