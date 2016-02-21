# Synchronisation

* [Synchronisation totale du site](#synchronisationtotale)
* [Synchronisation “Remote-File”](#synchroremotefile)


La synchronisation concerne deux choses :

* Le check de la totalité du site, avec possibilité de synchroniser tous les fichiers distants (cf. [Synchronisation totale du site](#synchronisationtotale)).
* La synchronisation ciblée d'un fichier particulier (cf. [Synchronisation “Remote-File”](#synchroremotefile)).

<a name='synchronisationtotale'></a>

## Synchronisation totale du site

Pour lancer la synchronisation du site, il suffit de rejoindre la console (depuis la marge gauche) et de taper la ligne de commande :

    > check synchro

Le check se lance et une page HTML s'ouvre permettant de synchroniser les pages qui ne sont pas synchronisées.


<a name='synchroremotefile'></a>

## Synchronisation “Remote-File”

La synchronisation “remote-file” est un mécanisme qui permet d'actualiser facilement (très facilement…) un fichier particulier. C'est le mécanisme qui est utilisé par exemple pour les bases de données qui peuvent être éditées en distant (Scéndoco, Filmodico) et qui doivent être rapatriées en local pour pouvoir être à jour.

Dans une page, il suffit d'indiquer :

    # Dans 'monobjet/synchro.erb'
    #
    ...

    <% site.require_module 'remote_file' %>
    <%=
        RFile::new("./to/mon/fichier.ext").
        bloc_synchro(verbose: true)
    %>

Ce code :

* vérifie l'état des deux fichiers local et distant ;
* propose un bouton pour updater l'un des deux fichiers (dans le sens logique pour prendre le fichier le plus à jour) ;
* gère la synchronisation quand on clique sur ce bouton.

### Paramètres de `bloc_synchro`

La méthode `bloc_synchro` peut comporter les paramètres suivants :

    verbose       Si true, on affiche toujours l'état des deux fichiers,
                  même lorsqu'ils sont synchronisés

    action        Définit le "ACTION" du formulaire qui appelle la
                  synchronisation
                  Par défaut, la méthode prend la route courante, donc c'est
                  le même fichier qui est sollicité pour traiter la synchro.
                  Si un autre fichier est invoqué, il faut s'assurer qu'il
                  contient bien le même code RFile::new... cf. plus haut.
