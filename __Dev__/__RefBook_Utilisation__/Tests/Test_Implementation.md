# Implémentation

* [Méthodes de tests des Files](#fichierdefinissantlesmethodesdetestdefile)
<a name='fichierdefinissantlesmethodesdetestdefile'></a>

## Méthodes de tests des Files
Ce que j'appelle les "méthodes de tests des Files", ce sont les méthodes principales qu'on peut trouver dans les fichiers `spec`. Par exemple, la méthode `test_route` est une méthode de tests de files :

        test_route "ma/route" do |r|
          r.responds
          r.has_title("Bienvenue !", 1)
          r.has_tag("section#content")
        end

Ces méthodes se définissent dans le fichier :


        ./lib/deep/deeper/module/test/TestFile/test_methods.rb

S'inspirer des méthodes de ce fichier pour composer les autres méthodes
