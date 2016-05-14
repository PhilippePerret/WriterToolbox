# DSLTestClass

C'est la classe dont doit hériter toute classe de test.

Par exemple, `test_form`, qui teste les formulaires, est défini par :

~~~ruby

    class SiteHtml
      class TestSuite
        class TestForm < DSLTestClass

          ...

~~~

* [Méthode `init`](#methodeinit)
<a name='methodeinit'></a>

## Méthode `init`

La méthode `init` est appelée tout de suite après l'instanciation.
