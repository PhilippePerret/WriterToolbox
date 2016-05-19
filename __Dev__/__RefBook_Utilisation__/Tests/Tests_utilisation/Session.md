# Session au cours des tests

* [Ré-initialisation de la session](#reinitialiserunesession)


<a name='reinitialiserunesession'></a>

## Ré-initialisation de la session

La session est maintenue à l'intérieur d'un fichier de tests entre les différents appels des pages à l'aide d'un fichier qui contient l'HEADER (et notamment le cookie de la variable de session).

On peut initialiser cette session en utilisant la méthode `reset_session` à l'intérieur d'une méthode de test. Noter cependant que cette initialisation se fait toujours entre les différentes feuilles de test.

Par exemple&nbsp;:

~~~ruby

test_route "ma/route" do
  reset_session
  responds
end

~~~

Si l'on doit réinitialiser la session en dehors d'une test-méthode, on peut utiliser&nbsp;:

~~~ruby

SiteHtml::TestSuite::Request::CURL::reset_session

~~~
