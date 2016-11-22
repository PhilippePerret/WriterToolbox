# Fichiers tests


* [Définition](#definitionidesfichierstests)
* [Description du fichier-test pour le rapport](#descriptiondufichiertestpourletest)
* [Options des fichiers de tests](#optionsdesfichiersdetests)

<a name='definitionidesfichierstests'></a>

## Définition

Les fichiers tests sont les fichiers ruby décrivant les tests.

Ils sont composés de `test-méthodes` ou “méthodes test”.

<a name='descriptiondufichiertestpourletest'></a>

## Description du fichier-test pour le rapport

On peut décrire le fichier test, pour l'information et pour l'affichage du rapport final en utilisant la méthode `description` (qui peut être mise n'importe où dans le fichier, même tout en bas).

~~~ruby

description <<-MARKDOWN

MARKDOWN

~~~

Comme indiqué, cette description se fait au format `Markdown` (`Kramdown`) et donc peut être assez complète et expressive. Par exemple&nbsp;:

~~~ruby

description <<-MARKDOWN

Ce test s'occupe&nbsp;:

* de valider ça,
* et de valider ça,
* et de s'assure que ça.

On peut vérifier que c'est utile en consultant [ce lien](http://unlienpourvoir.com)

MARKDOWN
~~~

<a name='optionsdesfichiersdetests'></a>

## Options des fichiers de tests

On peut définir qu'une feuille de tests ne doit se faire qu'en offline ou en online en indiquant dans son entête, **avant le premier test**&nbsp;:

~~~ruby

only_offline
    # Le test ne sera joué que si on teste en offline (local)


only_online
    # Le test ne sera joué que si on teste en online (distant)
