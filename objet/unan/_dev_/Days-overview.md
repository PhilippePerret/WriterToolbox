# Aperçu par bits

* [Constantes Bits et valeur](#valeurdesbitesetconstantes)
* [Retrouver la valeur d'un jour particulier](#retrouvervaleurjourparticulier)
* [Ajouter une valeur à un day-overview](#ajoutervaleuradayoverview)


L'“aperçu par bits” est une donnée d'un programme (`days_overview`) qui permet d'avoir un aperçu complet du programme de l'auteur.

Cette propriété a une longueur de 365 x 2 chiffres, chiffres de 0 à v (base 32) où chaque paire représente un jour-programme.

    days_overview  BLOB  365 x 2 = 730 chars

Les deux chiffres de 0 à v en base 32 donne donc un nombre de 0 à 1023 qui, en binaire, **mesure donc 10 bits**.

Chaque bit représente une propriété général de l'état du jour-programme.


    Longueur de la donnée :
    -----------------------
        365 * 2 = 730
        Donc 0 * 730 au départ
        # => days_overview
        Sauf qu'on ne va pas tout initialiser. Un jour qui n'est pas défini
        est à 0 dans le programme.


    La valeur pour chaque jour :
      * est un double chiffre de 0 à v (base 32)
      * Donne un nombre de 0 à 1023 en décimal
      * Produit la possibilité d'avoir 10 bits

Pour les bits, cf. [Constantes Bits](#valeurdesbitesetconstantes).

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
    
