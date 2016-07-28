# Tests RSpec

* [Définition de la route dans un test unitaire](#definirroutedansunitaire)

On peut lancer les tests `rspec` de façon traditionnelle à l'aide du Terminal, ou en utilisant la console RestSite :

        $> rspec "folder/from/rspec-folder/"[ online|offline]

Par exemple, pour lancer les tests du dossier :

        ./spec/online/mini/accueil/

        $> rspec mini/accueil online

<a name='definirroutedansunitaire'></a>

## Définition de la route dans un test unitaire

Intuitivement, j'aimerais faire :

    param(route: 'la/route')

Mais il faut décomposer en `__o`, `__i`, etc.

Utiliser la méthode du spec-helper :

    set_route <route>

Où `<route>` peut définir le contexte :

    before :all do
      set_route 'objet/objet_id/method?in=context'
    end
