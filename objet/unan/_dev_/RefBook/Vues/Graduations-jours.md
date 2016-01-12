# Graduations jours

* [Résumé](#resumedelamethode)
* [Description de la méthode `graduation_jours`](#descriptiondelamethode)
* [Arguments de la méthode `graduation_jours`](#parametrestransmissibles)



<a name='resumedelamethode'></a>

## Résumé

    Unan::Helper::graduation_jours(
      day_width: <largeur>,
      from: <jour départ | 1>,
      to:   <jour fin | 364>
      )

Cf les [arguments de la méthode `graduation_jours`](#parametrestransmissibles) pour voir tous les arguments possibles;

Note : Si on se trouve dans la partie administration, il faut requérir l'objet `Unan` :

    site.require_objet 'unan'

<a name='descriptiondelamethode'></a>

## Description de la méthode `graduation_jours`

La méthode `graduation_jours` permet de construire une graduation de jours dans n'importe quel div (carte ou autre).

**Requis**

* Le div conteneur doit être `position:relative` (ou `absolute`, `fixed`).

<a name='parametrestransmissibles'></a>

## Arguments de la méthode `graduation_jours`

    day_width   [OBLIGATOIRE]

        Largeur d'un jour donc d'une graduation, en pixel

    from

        L'indice 1-start du premier jour
        Par défaut : 1


    to

        L'indice 1-start du dernier jour de la graduation
        Par défaut : 365

    background_color

        La couleur à utiliser pour la règle
        Par défaut : un peu jaune, comme un mètre dépliant

    color

        La couleur à utiliser pour les graduations
        Par défaut : un gris

    padding_left

        Le décalage gauche à utiliser. C'est le padding du
        conteneur.
        Par défaut : 12px

    by

        Le pas à utiliser pour afficher les jours
        Par défaut : 1 (jour)
        NOTE : Pas encore implémenté
