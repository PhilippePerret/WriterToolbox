# Méthodes HTML

Ce fichier contient différentes méthodes qui ne peuvent pas être classées ailleurs concernant les documents HTML.

Pour obtenir tout ce qu'on veut dans un document HTML, on peut utiliser&nbsp;:

~~~ruby

  html.page.<...>
  
~~~

Par exemple, si l'on veut tous les liens `a` définissant l'attribut `href`&nbsp;:

~~~ruby

  liens = html.page.css('a[href]')