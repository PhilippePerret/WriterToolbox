# Mise en forme des vues

* [Mise en forme de TEXTE](#misteenformedetexte)
  * [Différentes mises en forme fréquentes](#differentesmisesenformeparcss)
  * [Rendre un texte/élément plus discret](#rendreuntexteplusdiscret)
* [Mise en forme de SECTIONs/DIVs](#miseenformedesectionsdetexte)
  * [Dimensionnement par la classe](#dimensionnementparlaclasse)
  * [Données tabulaires](#donneestabulaires)
* [Mise en forme des FORMULAIRES](#miseenformedesformulaires)
* [Mise en forme des LISTES](#miseneformedeslistes)



<a name='misteenformedetexte'></a>

## Mise en forme de TEXTE

<a name='differentesmisesenformeparcss'></a>

### Différentes mises en forme fréquentes

    .italic

        Met le contenu en italique

    .bold

        Met le contenu en gras

    .right

        Aligne le contenu à droite

    .center

        Centre le contenu
        
    .fright

        Rend l'élément flottant à droite

    .fleft

        Rend l'élément flottant à gauche

    .warning

        Écrit en rouge

    .small

        Écrit le contenu en plus petit

    .big

        Écrit le contenu en gros

<a name='rendreuntexteplusdiscret'></a>

### Rendre un texte/élément plus discret

    .discret      # réagit au survol de la souris

Pour le rendre encore plus discret, on peut ajouter `tres` à sa classe.

    <div class="tres discret">...</div>

Noter que cette discrétion joue sur l'opacité et que le texte sera rendu plus lisible et visible lorsqu'on le survolera de la souris.

<a name='miseenformedesectionsdetexte'></a>

## Mise en forme de section/divisions

<a name='dimensionnementparlaclasse'></a>

### Dimensionnement par la classe


On peut utiliser les classes `wXXX` pour déterminer la largeur en pixels de l'élément.

Valeurs utilisables : 40, 50, 60, 80, 100, 120, 140, 150, 180, 200, 240, 280, 300.

Par exemple, le code `<div class="w80">...</div>` produira un DIV de largeur de 80 pixels.

<a name='donneestabulaires'></a>

### Données tabulaires


Pour être cohérent avec les formulaires, on peut afficher les données à l'aide de :
    div.dimXXYY
      div.row
        span.libelle
        span.value

Par exemple :

    <div class="dim2080">
      <div class="row">
        <span class='libelle'>Le libellé</span>
        <span class='value'>La valeur de la donnée ou du texte</span>
      </div>
      ...
    </div>

<!-- --------------------------------------------------------------------- -->

<a name='miseneformedeslistes'></a>

## Mise en forme des listes

Il existe plusieurs classes de listes intéressantes :

### Pour isoler la liste, la mettre ne relief dans la page

    ul.free
    ol.free

### Pour ajouter une border à gauche

    ul.bordure

### Pour décrire une procédure, principalement dans l'aide

    ol.procedure

      li.resultat       # Pour décrire le résultat (moins visible)

      li.main_action    # Pour mettre en exergue l'action principale

### Listes de description

On peut bien sûr utiliser les listes de description à l'aide de :

    <dl>

      <dt> le titre de la description </dt>

      <dd> la définition </dd>

      ...

    </dl>

<a name='miseenformedesformulaires'></a>

## Mise en forme des FORMULAIRES

cf. le fichier Vues > Formulaires.
