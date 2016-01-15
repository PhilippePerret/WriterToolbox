# Variables programme de l'user

* [Listing complet des variables courantes](#listingcompletdesvariables)
* [Indice du jour-programme (p-day) courant](#jourprogrammecourant)
* [Préférences](#lespreferences)


<a name='listingcompletdesvariables'></a>

## Listing complet des variables courantes

**Cette liste doit tenir à jour la liste complète des variables dans la table `variables` d'un user inscrit au programme UN AN UN SCRIPT.**

    pref_rythme

        Le rythme courant de l'auteur, de 1 à 9
        <- user.rythme
        <- user.preference(:rythme)

    current_pday

        Le jour-programme courant de l'auteur.
        <- user.get_var :current_pday
        <- user.pday

    pref_sharing

        Niveau de partage du projet de l'auteur
        <- user.preference(:sharing)


<a name='jourprogrammecourant'></a>

## Indice du jour-programme (p-day) courant

    :current_pday

On l'obtient par :

    get_var(:current_pday)

<!-- --------------------------------------------------------------------- -->

<a name='lespreferences'></a>

## Préférences

Pour les préférences, cf. le fichier RefBook User > Preferences.md.
