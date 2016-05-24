# Tests-méthodes de bases de données


## `test_base`

Permet de tester les bases de données. Exemple&nbsp;:

~~~ruby

  test_base "path/to/base.table" do
    has_row({id: 12, phil: "Phil", activity: 13})
  end

  test_base "users.users"{ row(2).exists }

~~~

@syntaxe

~~~ruby

  test_base "<base sans .db>.<table>" do
    <case-méthode>
    <case-méthode>
    ...
  end
~~~
