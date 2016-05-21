# Méthodes de débuggage

* [Options de la méthode `debug`](#optionsdelamethodedebugtest)

Les méthodes du fichier `./lib/deep/deeper/module/test/first_required/dsl/DSLTestClass/debug.rb` augmentent la méthode `debug` originale.

Il faut se trouver dans une test-méthode pour les utiliser.

Par exemple

~~~ruby

test_route "ma/route" do

  exists
  
  debug html
    # => Met dans le débug le code HTML de l'élément SiteHtml::TestSuite::HTML
    #    de la page.
  
end

~~~

<a name='optionsdelamethodedebugtest'></a>

## Options de la méthode `debug`

Contrairement à la méthode originale, la méthode débug peut recevoir des options qui dépendent de l'élément envoyé en argument.

### `debug html`

> Les options ci-dessous ne semblent pas fonctionner…

~~~

  :head           Si false (défaut: false), seul la balise <body> sera 
                  rendue.
  :body           Si false (défaut: true), le body ne sera pas rendu.
  :left_margin    Si false (true par défaut) la marge gauche ne sera pas 
                  donnée.
  :right_margin   Si false (true par défaut) la marge droite ne sera pas
                  donnée

~~~