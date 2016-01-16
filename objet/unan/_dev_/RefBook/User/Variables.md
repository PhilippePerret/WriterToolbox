# Variables programme de l'user

* [Listing complet des variables courantes](#listingcompletdesvariables)
* [Indice du jour-programme (p-day) courant](#jourprogrammecourant)
* [Préférences](#lespreferences)


<a name='listingcompletdesvariables'></a>

## Listing complet des variables courantes

**Cette liste doit tenir à jour la liste complète des variables dans la table `variables` d'un user inscrit au programme UN AN UN SCRIPT.**

**Noter que les variables sont classées dans leur ordre d'importance et donc qu'on trouve pêle-mêle des préférences et des variables normales.**

    pref_rythme

        {Fixnum} Le rythme courant de l'auteur, de 1 à 9
        <- user.rythme
        <- user.preference(:rythme)

    current_pday

        {Fixnum 1-start} Le jour-programme courant de l'auteur.
        <- user.get_var :current_pday
        <- user.pday

    pref_daily_summary

        {Boolean} True si l'auteur veut recevoir des récapilatifs
        journaliers même lorsqu'il n'a pas de nouveau travail.
        Défault : false

    works_ids

        {Array} Liste des IDs de travaux (work) en cours pour l'auteur.
        Noter qu'il s'agit des instances Unan::Program::Work, pas des
        travaux absolus.
        La liste est alimentée d'un côté par les changements de p-days
        et de l'autre pour les travaux accomplis.
        <- user.get_var :works_ids
        -> user.set_var :works_ids

        Note : `user.nombre_de(:works)` retourne le nombre ou 0

    quiz_ids

        {Array} Liste des IDs des questionnaires (quiz) que doit remplir
        l'auteur. La liste es alimentée d'un côté par les changements de
        p-days et de l'autre pour les questionnaires effectués par l'auteur.
        <- user.get_var :quiz_ids
        -> user.set_var :quiz_ids

        Note : `user.nombre_de(:quiz)` retourne le nombre, ou 0

    messages_ids

        {Array} Liste des IDs des messages (forums ou non) actuels de
        l'auteur.

        <- user.get_var :messages_ids
        -> user.set_var :messages_ids

        Note : `user.nombre_de(:messages)` en retourne le nombre, ou 0

    pages_cours_ids

        {Array} Liste des IDs des pages de cours courantes (à lire ou
        lues). Elles ne dépendant que des p-days courants et précédents
        en fonction de la durée de lecture de la page.

        <- user.get_var :pages_cours_ids
        -> user.set_var :pages_cours_ids

        user.nombre_de(:page_cours) en retourne le nombre, ou 0

    pages_non_lues_ids

        {Array} Liste des IDs des pages de cours non lues par rapport
        aux pages de cours à lire (pages_cours_ids)

        <- user.get_var :pages_non_lues_ids
        -> user.set_var :pages_non_lues_ids

        user.nombre_de(:pages_non_lues) en retourne le nombre, ou 0

    pref_sharing

        {Fixnum} Niveau de partage du projet de l'auteur
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
