# Le fichier `./test/run`

* [Définir la liste des fichiers tests](#definirlalistedesfichiers)
* [Définir le lieu des tests (distant/local)](#definironlineoffline)


  test run
  
  run test
  
  
<a name='definirlalistedesfichiers'></a>

## Définir la liste des fichiers tests

Utiliser `test_files`&nbsp;:

    SiteHtml::TestSuite.configure do 
      
      current.files = [liste de fichiers-test]
      
    end

On peut spécifier chaque élément de trois façons différentes&nbsp;:

* en version “intégrale”&nbsp;: "./test/mini/mon_test_spec.rb",
* en version relative depuis ./test/mini&nbsp;: "mini/mon_test_spec.rb",
* en version relative simple&nbsp;: "mini/mon_test" (noter qu'ici l'application ajoute `./test` devant et `_spec.rb` au nom du fichier).

<a name='definironlineoffline'></a>

## Définir le lieu des tests (distant/local)

    SiteHtml::TestSuite.configure do
    
      current.options[:offline] = true
      
      OU
      
      current.options[:online] = false
      
    end