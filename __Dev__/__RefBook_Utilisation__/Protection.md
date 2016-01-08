# Protections

* [Protéger les accès aux vues/modules](#protegeraccesavue)
* [Personnaliser les pages d'interdiction](#personnaliserpageraise)


<a name='protegeraccesavue'></a>

## Protéger les accès aux vues/modules

Deux méthodes permettent de protéger l'accès aux modules ou aux vues :

    # Pour interdire l'accès à une vue/module sans être identifié
    raise_unless_identified

    # Pour interdire l'accès à une vue/module sans être administrateur
    raise_unless_admin

    # Pour interdire l'accès à une vue/un module suivant certaines
    # condition :
    raise_unless <condition_a_remplir>


Par exemple en haut d'une vue :

    <% raise_unless_identified %>

    ou

    <% raise_unless_admin %>

    ou
    (pour interdire à une administrateur ou un user abonné au site)

    <% raise_unless( user.admin? || user.subscribed? ) %>

Noter que ces méthodes interrompent la suite pour afficher une page spéciale définie de façon standard dans les fichiers :

    ./view/deep/deeper/page/error_unless_identified.erb
    ./view/deep/deeper/page/error_unless_admin.erb
    ./view/deep/deeper/page/error_unless_condition.erb

Pour définir une page personnalisée, voir [Personnaliser les pages d'interdiction](#personnaliserpageraise) ci-dessous.

<a name='personnaliserpageraise'></a>

## Personnaliser les pages d'interdiction

On peut créer des pages d'interdiction en créant les fichiers :

    ./view/site/error_unless_identified.erb
    ./view/site/error_unless_admin.erb
    ./view/site/error_unless_condition.erb
