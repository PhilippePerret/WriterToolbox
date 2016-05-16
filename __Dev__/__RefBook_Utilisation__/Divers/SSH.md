# SSH

* [Require des gems propres](#requiregempropre)

<a name='requiregempropre'></a>

## Require des gems propres



Pour utiliser `require 'sqlite3'` dans un code SSH ruby ou tout autre appel d'un gem, il faut impérativement utiliser, malheureusement :

    $: << '/home/boite-a-outils/.gems/gems/sqlite3-1.3.10/lib'
    require 'sqlite3'
