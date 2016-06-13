# Javascript

* [Snippets](#snippetspourvue)
* [Obtenir des codes par UI.clip](#uiclip)


<a name='snippetspourvue'></a>

## Snippets

Pour les snippets, lire le manuel :

    ./lib/deep/deeper/js/optional/Snippets_manual.md

<a name='uiclip'></a>

## Obtenir des codes par UI.clip

La méthode `UI.clip` permet de donner des codes par javascript, à copier-coller. C'est la méthode qui est utilisée, par exemple, pour donner les codes d'une citation, à copier-coller n'importe où : mail, page, etc.

Utilisation :

    "&lt;CODES&gt;".in_a(
      onclick:"UI.clip({
        '<titre code>': '<le code à copier-coller>',
        '<titre code>': '<le code à copier-coller>',
        etc.
        })")

Rappel : pour faire disparaitre l'encart, il faut couper le code et faire tabulation pour en sortir. La fenêtre se ferme automatiquement.
