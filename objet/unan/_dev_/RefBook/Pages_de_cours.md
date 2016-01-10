# Pages de cours

* [Dossier des pages de cours](#dossierdespagesdecours)
* [Les Pointeurs de page](#leshandlersdepage)
* [Lien pour afficher/éditer/détruire une page de cours](#lienpourafficherunepagedecours)
* [Instance de page de cours (`page_cours()`)](#instancedepagedecours)
* [Map des pages de cours](#mapdespagesdecours)

<a name='lienpourafficherunepagedecours'></a>

## Lien pour afficher/éditer/détruire une page de cours

Fonctionnellement, suivant le principe restfull du site, on utilise pour afficher une page de cours, pour l'éditer ou pour la détruire, respectivement :

    href="page_cours/<id>/read?in=unan"

    href="page_cours/<id>/edit?in=unan"

    href="page_cours/<id>/destroy?in=unan"

Mais on préfèrera utiliser la méthode pratique utilisant [les pointeurs](#leshandlersdepage) :

    page_cours(<hanlder>).link[ "<titre>"]

On obtient les liens par :

    page_cours(<ref>).link            # lien pour afficher la page
                                      # read.erb
    page_cours(<ref>).link(:edit)     # => lien pour éditer la page
                                      # edit.erb
    page_cours(<ref>).link(:destroy)  # => lien pour détruire la page
                                      # destroy.erb

Cf. [Instance de page de cours](#instancedepagedecours) pour le détail de cette méthode pratique.

**Noter qu'on peut aussi utiliser les ID avec cette méthode, mais que c'est moins parlant. Par exemple :**

    page_cours(:introduction_au_programme).link

… est + parlant que :

    page_cours(12).link

D'autre part, si on modifie la table des pages de cours, il suffira de changer la [map des pages de cours](#mapdespagesdecours) pour corriger tous les liens d'un coup.

<a name='instancedepagedecours'></a>

## Instance de page de cours

Pour obtenir une instance de page de cours (`{Unan::Program::PageCours}`), on peut utiliser la méthode pratique `page_cours`.

Elle est définie dans le fichier principal des méthodes pratiques :

    ./objet/unan/lib/required/handy.rb

<a name='mapdespagesdecours'></a>

## Map des pages de cours

Ce que j'appelle la “map des pages de cours”, c'est la correspondance entre le handler (Symbol explicite) et l'ID de la table.

<a name='leshandlersdepage'></a>

## Les Pointeurs de page


<a name='dossierdespagesdecours'></a>

## Dossier des pages de cours

Pour le moment, toutes les pages de cours, qu'elles soient propre au programme ou qu'elle provienne du livre ou de la collection Narration, se trouvent respectivement dans les dossiers :

    ./data/unan/ unan/        Dossier des pages propres au programme
                 narration/   Pages du livre
                 cnarration/  Pages de la collection
