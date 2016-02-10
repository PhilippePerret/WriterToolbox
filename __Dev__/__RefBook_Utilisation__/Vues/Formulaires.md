# Formulaire


* [Dimensions des colonnes de libellé et de value](#dimensionsdeuxcolonnes)
* [Requérir les méthodes pratiques](#requerirmethodespratiques)
* [Méthodes de construction des champs](#methodesdechamp)
* [Options pour les champs](#optionspourleschamps)
* [Définir un préfix pour NAME et ID](#definirunprefixpourlesnameetid)

<a name='dimensionsdeuxcolonnes'></a>

## Dimensions des colonnes de libellé et de value

On peut utiliser les classes suivantes pour définir la largeur de la colonne des libellés (colonnes gauche) et la colonne des valeurs (colonnes droites) où seront placés les champs d'édition (ou autre).

Le principe du nom du sélecteur est le suivant : les deux premiers chiffres correspondent au pourcentage de place pour la colonne des libellés et les deux chiffres suivant correspondent au pourcentage de largeur pour la colonne des valeurs.

    Selector CSS    Largeur     Largeur
                    libellés    Champs
    dim5050          50%         50%
    dim4060          40%         60%
    dim3070          30%         70%
    dim2080          20%         80%

*Note : En réalité, le total ne fait pas 100%, pour tenir compte des paddings et autres décalages. La somme est calculée sur 95%*.

*Note 2 : C'est dans le fichier `forms.sass` que sont définis ces styles.*

<a name='requerirmethodespratiques'></a>

## Requérir les méthodes pratiques

Au début de la vue, placer :

    site.require 'form_tools'

Cela chargera des méthodes pratique qui permettront de définir facilement les formulaires en utilisant des méthodes-raccourcis :


    Form::input_text("<libelle>", "<propriété>", "<value>"[, options])

Si aucun préfixe n'est défini (cf. [Définir un préfix pour NAME et ID](#definirunprefixpourlesnameetid)) alors `NAME` et `ID` vaudront `propriété`.

<a name='methodesdechamp'></a>

## Méthodes de construction des champs

### Construction d'une description

    form.field_description("<la description du champ>")

Ça n'est pas à proprement parler un champ d'édition, c'est un texte explicatif qui est placé — souvent en dessous du champ — pour le décrire.

### Construction d'un input-text

    form.field_text(<libelle>, <propriété>, <valeur def>, <options>)

Par exemple :

    <% form.prefix = "voyage" %>
    ...
    <%= form.field_text("Durée", 'duree', 10, {class: 'short'} )

Produira :

    <div class="row">
      <span class="libelle">Durée</span>
      <span class="value">
        <input type="text" name="voyage[duree]" id="voyage_id" value="10" class="short" />
      </span>
    </div>

### Construction d'un champ hidden

    form.field_hidden(nil, '<prop>', nil)

### Construction d'un textarea

    form.field_textarea(<params>)

### Construction d'un menu select

    form.field_select( <params> )

### Construction d'une case à cocher unique

    form.field_checkbox( <params> )

Noter que pour la case à cocher, le libellé (premier argument) servira de label. Il n'y aura donc pas de libellé, sauf explicitement indiqué dans les options (4e argument)

### Construction d'un ensemble de cases à cocher

    form.field_checkbox( <param> )

La différence par rapport à la case unique se fera à la définition des `values` dans le paramètres `options`, qui contiendra plusieurs valeurs au lieu d'une seule. La valeur par défaut, également, si elle est définie, sera un Array (liste des cases cochées) plutôt qu'une valeur unique.

<a name='optionspourleschamps'></a>

## Options pour les champs

    :class                  Class CSS à ajouter au champ d'édition quel
                            qu'il soit
    :text_after             Texte à placer après le champ (dans un span)
    :text_before            Texte à placer avant le champ (dans un span)
    :libelle_width          Largeur en pixels des libellés (100 par défaut)
                            Note : Ça ne définit pas le style, mais la classe
                            wLARGEUR (par exemple w100 par défaut). Donc il
                            faut une largeur existante
    :placeholder            Le placeholder du champ pour un champ de texte
                            Rappel : le "placeholder" sera le texte qui apparaitra
                            si le champ est vide. Il indique en général le
                            contenu attendu pour le champ.
    :confirmation           Si true, le champ est "doublé" pour présenter
                            un champ de confirmation (par exemple pour un
                            mail). Noter que le libellé sera construit à partir du libellé du champ à confirmer auquel sera ajouté, devant "Confirmation de" (le libellé sera capitalisé). Par exemple, si le champ s'appelle "Votre mail", le champ de confirmation aura pour libellé "Confirmation de votre mail".


<a name='definirunprefixpourlesnameetid'></a>

## Définir un préfix pour NAME et ID


On peut définir au début le préfixe qui permettre de définir les `id` et les `name` :

    Form::prefix = "<le préfixe>"

Par exemple :

    Si prefix = "user"
    Et propriété = "name"
    Alors le champ aura :
      name  = "user[name]"
      id    = "user_name"
