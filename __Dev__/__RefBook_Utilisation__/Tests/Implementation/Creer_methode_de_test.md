# Créer une nouvelle méthode de test

Une "méthode de test", c'est l'élément supérieur des feuilles de test, comme les "describe" dans RSpec.

On utilise un **DSL** particulier.

* Définir la classe, c'est-à-dire son nom. Par exemple `SiteHtml::TestSuite::TestForm`,
* Créer un dossier pour cette nouvelle méthode de test dans `./lib/deep/deeper/module/test/case_objets`,
* la faire hériter de `DSLTestMethod` après l'avoir fait descendre de `SiteHtml::TestSuite` :

    ~~~ruby
    
      class SiteHtml
      class TestSuite
      class TestForm < DSLTestMethod
      
    ~~~
* définir sa méthode d'initialisation :

    
          ...
          class TestForm < DSLTestMethod
            def initialize __ftest, param1... paramN, &block
              super(__ftest, &block)
            end

    
    Noter que `super` a besoin des parenthèses pour ses arguments et que c'est la référence à `block` qu'il faut transmettre (`&`).
    
    Noter que les paramètres seront ceux qui seront utilisés quand on utilisera la méthode de test dans la feuille de test, par exemple :
    
    `ftest` est l'instance `TestFile` du fichier test. Cf. plus bas.
    
    
        test_form param1,... paramN do

          ... ici le test ...
  
        end
    

* déterminer un nom de méthode de cette méthode de test, qui deviendra une méthode de la class `SiteHtml::TestSuite::TestFile` (dans `lib/deep/deeper/module/test/TestFile/test_methods.rb`) qui va permettre d'initialiser une instance de cette méthode de test :

    
      def <méthode test>, param1,... paramN, &bloc
        SiteHtml::TestSuite::<TestMethodClass>::new self, param1,... paramN, &bloc
      end

      Par exemple :
      
      def test_form param1... paramN, &bloc
        SiteHtml::TestSuite::TestForm::new self, param1... paramN, &bloc
      end

  Ne pas oublier le `self` comme premier argument qui fait référence au fichier de test

* lire les méthodes de la classe `DSLTestMethod` dans `./lib/deep/deeper/module/test/first_required/dsl/DSLTestMethod.rb` pour se souvenir des méthodes héritées, à commencer par `html`, qui permet d'avoir accès à tout le code de la dernière requête,
* définir une **description par défaut** dans la méthode `description_defaut` de la classe,

        class TestForm
          def description_defaut
            @description_defaut ||= "TEST FORM at ROUTE #{raw_route}"
          end
        end

* définir le **sujet** de la test-méthode, qui va permettre de gérer les missing_methods de type `?`. Par exemple, pour `test_user`, le sujet est l'user défini par le premier argument de la test-méthode.

        def subject
          @subject ||= <le sujet>
        end
        
* implémenter les méthodes de la nouvelle classe pour faire des *méthodes-case* dans un fichier `case_methods.rb` dans le dossier de la nouvelle classe de test.
