# Protections

* [Protéger les accès aux vues/modules](#protegeraccesavue)
* [Interruption du cours du programme](#interruptionducoursduprogramme)
* [Cas spécial du raise si non propriétaire (raise_unless_owern)](#casspecialowner)
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

    # Pour interdire l'accès lorsque l'user n'est pas le propriétaire
    # de la section (comme pour l'édition du projet par exemple)
    raise_unless_owner[ "<message précis à afficher>"]

Par exemple en haut d'une vue :

    <% raise_unless_identified %>

    ou

    <% raise_unless_admin %>

    ou
    (pour interdire à une administrateur ou un user abonné au site)

    <% raise_unless( user.admin? || user.suscribed? ) %>

    ou

    <% raise_unless_owner("Vous n'êtes pas le proprio ! ") %>

<a name='casspecialowner'></a>

## Cas spécial du raise si non propriétaire (raise_unless_owern)

Contrairement aux autres méthodes qui checkent dans leur corps la validité de la condition, la méthode `raise_unless_owner` doit être appelée après avoir fait la vérification et seulement si cette vérification échoue.

En d'autres termes, on peut utiliser toute seule :

    raise_unless_identified
    # Raise si l'user n'est pas identifié

Mais on doit utiliser :

    if user_is_not_auteur_de_cette_section
      raise_unless_owner "L'auteur n'est pas le proprio, ici"
    end

Prendre note également qu'IL EST INUTILE DE TESTER SI C'EST UN ADMINISTRATEUR car un administrateur a tous les droits à ce niveau et passera toujours avec succès la méthode `raise_unless_owner`.

<a name='interruptionducoursduprogramme'></a>

## Interruption du cours du programme

Ces méthodes interrompent la suite pour afficher une page spéciale définie de façon standard dans les fichiers :

    ./view/deep/deeper/page/error_unless_identified.erb
    ./view/deep/deeper/page/error_unless_admin.erb
    ./view/deep/deeper/page/error_unless_condition.erb
    ./view/deep/deeper/page/error_unless_owner.erb

Pour définir une page personnalisée, voir [Personnaliser les pages d'interdiction](#personnaliserpageraise) ci-dessous.

<a name='personnaliserpageraise'></a>

## Personnaliser les pages d'interdiction

On peut créer des pages d'interdiction en créant les fichiers :

    ./view/site/error_unless_identified.erb
    ./view/site/error_unless_admin.erb
    ./view/site/error_unless_condition.erb
    ./view/site/error_unless_owner.erb
