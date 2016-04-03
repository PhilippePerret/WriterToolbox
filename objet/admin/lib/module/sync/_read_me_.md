# Sync

* [Description](#descriptionmodule)
* [LE CHECK](#lecheck)
* [LE DISPLAY](#ledisplay)
* [LA SYNCHRO](#lasynchro)

<a name='descriptionmodule'></a>

## Description


Ce module permet de faire un état des lieux de la boite à outils
ainsi que de l'atelier Icare au niveau des fichiers qui doivent
être synchronisés, affiche cet état et permet de procéder à une
synchronisation.

Ces trois fonctions entrainent trois parties :

1/ Partie 1, appelée : LE CHECK       Procède à la vérification
2/ Partie 2, appelée : LE DISPLAY     Affichage de l'état de synchro
3/ Partie 3, appelée : LA SYNCHRO     Procède à la synchronisation

<a name='lecheck'></a>

## LE CHECK


    Par SSH, on vérifie l'état des fichiers définis dans FILES2SYNC
    et on reçoit un Hash contenant les données checkées.

    Ce résultat est enregistré dans le fichier en Marshal :

      method:   check_data_path
      path:     ./tmp/sync/check_data.msh

    Lors d'un rechargement de page, si ce fichier existe et qu'il
    est moins vieux qu'une heure, il est utilisé pour lire l'état
    des lieux. Sinon, il est détruit et on check à nouveau. Ce check
    peut être néanmoins forcé par un bouton.

    La données

<a name='ledisplay'></a>

## LE DISPLAY

    La partie “display” du module, qui affiche les résultats du check
    de la synchro sur le site distant et sur l'atelier Icare.

    Ce display est enregistré dans un fichier HTML qui n'est actualisé
    que s'il date de plus d'une heure :

        method:   display_path
        path:     ./tmp/sync/display.html

<a name='lasynchro'></a>

## LA SYNCHRO

    La partie “synchro” permet de procéder à la synchronisation proprement
    dite.

    Les données de synchronisation qui vont permettre de procéder à cette
    synchronisation sont consignées dans un fichier marshal :

        method:   synchro_data_path
        path:     ./tmp/sync/synchro_data.msh

      method: data_synchronisation
      return: {Hash} contenant les informations sur la synchronisation à
              faire.

      method: data_synchronisation= <data>
