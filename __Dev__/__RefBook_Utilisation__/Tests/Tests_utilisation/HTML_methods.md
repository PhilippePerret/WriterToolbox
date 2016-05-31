# Méthodes HTML

* [Inspecter le contenu de la page](#inspecterlecontenudelapage)
* [Mettre le débug en débug](#retournerledebugendebug)

Ce fichier contient différentes méthodes qui ne peuvent pas être classées ailleurs concernant les documents HTML.

Pour obtenir tout ce qu'on veut dans un document HTML, on peut utiliser&nbsp;:

~~~ruby

  html.page.<...>
  
~~~

Par exemple, si l'on veut tous les liens `a` définissant l'attribut `href`&nbsp;:

~~~ruby

  liens = html.page.css('a[href]')
  
  
<a name='inspecterlecontenudelapage'></a>

## Inspecter le contenu de la page

~~~ruby

  test_route "ma/route" do
  
    html.inspect
    # => Ecrit dans le debug le contenu intégral de
    #    la page ma/route.
    
  end
  
~~~

<a name='retournerledebugendebug'></a>

## Mettre le débug en débug

Méthode `debug_debug` de l'objet `html`.

On peut afficher dans le débug de la page de test (console) le debug produit par la page courante (obtenue par CURL)&nbsp;:

~~~ruby

  test_route "ma/route" do
  
    html.debug_debug
    # => Place dans le débug le contenu du debug de ma/route
    
  end
~~~