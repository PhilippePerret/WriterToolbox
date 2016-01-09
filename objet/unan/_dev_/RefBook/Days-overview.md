# Aperçu par bits

* [Présentation du principe général](#principegeneralepresentation)
* [Les classes `DaysOverview` et `DaysOverview::Day`](#classedaysoverview)
* [Constantes Bits et valeur](#valeurdesbitesetconstantes)
* [Tester la valeur d'un bit](#testerpresencebit)
* [Retrouver la valeur d'un jour particulier](#retrouvervaleurjourparticulier)
* [Ajouter une valeur à un day-overview](#ajoutervaleuradayoverview)


<a name='principegeneralepresentation'></a>

## Présentation du principe général

`days_overview` est une donnée d'une instance `Unan::Program` (un programme “Un An Un Script”) qui permet d'avoir un aperçu général de chacun des 364 (365) jours de travail du programme suivi par un auteur.

Chaque jour est représenté par un nombre sur deux caractères, en base 32, donc des valeurs de "00" à "vv" (de 0 à 1023 en décimal).

Il y a donc 365 x 2 caractères (730) dans la valeur de `days_overview`.

En binaire, chaque "valeur-jour" (les 2 caractères du jour) contient 10 bits :

    0  = 0000000000
    vv = 1111111111

Chaque bit représente une propriété général de l'état du jour-programme concerné. Cf. [Constantes Bits](#valeurdesbitesetconstantes).

---------------------------------------------------------------------


<a name='classedaysoverview'></a>

## Les classes `DaysOverview` et `DaysOverview::Day`

Pour gérer la propriété `days_overview` (qui est assez complexe à cause de sa longueur et des bases), on a deux classes :

    Unan::Program::DaysOverview
    # -> Gère la donnée général et les jours

    Unan::Program::DaysOverview::Day
    # -> Gère un jour-programme particulier

On obtient une instance `DaysOverview` du programme par :

    iprogram.days_overview

    # Où `iprogram` a pu être obtenu par :
    iprogram = user.program
    # => Le Unan::Program de l'auteur courant

On obtient un jour quelconque par :

    iprogram.day_overview(ijour_1_start)
    # => Instance {Unan::Program::DaysOverview::Day} du jour

* [Méthodes de DaysOverview::Day](#methodededaysoverviewday)
<a name='methodededaysoverviewday'></a>

## Méthodes de DaysOverview::Day

Une fois qu'on a obtenir un jour par :

    day = iprogramme.day_overview jour12

… on peut utiliser les méthodes :

    day.value
    # {Fixnum} valeur numérique du jour
    # => 598

### Méthodes sur les bits

    day.add_bit_<constante bit minuscule sans "b_">
    # => Ajoute la valeur du bit voulu

    day.bit_<constante bit min sans b_>?
    # => Retourne true si le bit est actif

    day.remove.bit<constante bit minuscule sans "b_">
    # => Retire la valeur du bit voulu

Pour les constantes, cf. [Constantes Bits et valeur](#valeurdesbitesetconstantes)

Par exemple :

    day.add_bit_actif
    day.add_bit_mail_deb
    day.add_bit_forc_fin

    day.remove_bit_actif
    day.remove_bit_forc_fin


<a name='valeurdesbitesetconstantes'></a>

## Constantes Bits et valeur

    B_ACTIF    = 1    # Bit ( 1) d'activité
      Ce bit est à 1 quand le jour-programme est en cours
      Noter qu'il peut arriver que plusieurs jours-programme soient en
      activité en même temps.

    B_MAIL_DEB = 2    # Bit ( 2) de mail d'annonce
      Au démarrage du jour d'activité, un mail d'annonce est envoyé
      à l'auteur pour lui présenter son programme.
      Dès que le mail est envoyé, ce bit est activité

    B_CONF_DEB = 4    # Bit ( 3) de confirmation de démarrage par auteur
      La première chose que doit faire l'auteur, c'est confirmer le
      démarrage de son travail. Dès qu'il l'a fait, ce bit est mis à 1

    B_MAIL_FIN = 128  # Bit ( 8) de mail de fin
    B_FORC_FIN = 256  # Bit ( 9) de fin forcée
        Bit activé lorsque c'est l'auteur lui-même qui force la fin du
        travail, alors qu'il n'a pas le nombre de points nécessaire pour
        poursuivre, normalement.
    B_FIN      = 512  # Bit (10) de fin (forcée ou non)

<a name='testerpresencebit'></a>

## Tester la valeur d'un bit

Pour tester la valeur d'un bit, on utilise les méthodes de la forme :

    <constante bit minuscule sans b_>?

Par exemple :

    Pour le bit B_ACTIF
    => actif?
    Pour le bit B_CONF_DEB
    => conf_deb?

Voir les valeurs de [Constantes Bits](#valeurdesbitesetconstantes).

Donc, dans le programme, on peut utiliser :

    jourp = user.program.day_overview( 110 )
    # => overview du 110e jour du programme (jour-programme, par jour réel)

    jourp.actif?
    # => true si le jour est actif, c'est-à-dire est courant
    jourp.mail_deb?
    # => true si le mail de début a été envoyé
    jourp.conf_deb?
    # => true si l'auteur a confirmé son démarrage
    jourp.mail_fin?
    # => true si le mail de fin a été envoyé
    jourp.forc_fin?
    # => true si l'auteur a forcé la fin de ce jour de travail
    jourp.fin?
    # => true si le jour est terminé

<a name='retrouvervaleurjourparticulier'></a>

## Retrouver la valeur décimal d'un jour particulier

C'est une méthode d'instance de `Unan::Program` et de `Unan::Program::PDay` :


    Unan::Programm#day_overview( <i jour 1-start> ).val10

    Unan::Programm::PDay#overview

Par exemple :

    Soit iprogram, une instance de Unan::Program

    dayo = iprogram.day_overview(123)
    value = dayo.val10
    ou
    value = dayo.value

<a name='ajoutervaleuradayoverview'></a>

## Ajouter une valeur à un day-overview

On utilise la méthode `<` qui ajoute à la valeur elle-même.

Par exemple :

    iprogram est une instance Unan::Program

    # Instance Unan::Program::DaysOverview::Day du 251e jour
    dayo = iprogram.day_overview( 251 ) # le 251e jour

    # Ajout du bit de fin forcé (qui vaut 256)
    dayo < B_FORC_FIN # ajoute le bit de la fin forcée
                      # ET L'ENREGISTRE

Noter qu'on peut passer directement par les méthodes, il y en a une par bit :

    dayo.add_bit_forc_fin
    # Change la valeur de bit et l'enregistre

* [Retirer des valeurs de bits](#retirervaleurdebit)
<a name='retirervaleurdebit'></a>

## Retirer des valeurs de bits

On peut utiliser la méthode `>` pour retirer des valeurs à chaque day-overview.

Mais comme les méthodes `add_bit_...` il existe les méthode `remove_bit_...` qui retire la valeur voulue.

Donc :

    dover = iprogram.day_overview( 101 )
    dover > B_MAIL_FIN
    # Retire la valeur B_MAIL_FIN au jour 101
    # et ENREGISTRE le nouveau days_overview

… équivaut à :

    dover = iprogram.day_overview( 101 )
    dover.remove_bit_mail_fin
