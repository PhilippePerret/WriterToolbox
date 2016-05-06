# Relecture de tous les scripts pour voir si c'est conforme
# à la nouvelle forme (sans liste d'identifiants)

* Manuel de développement OK (unan/_dev_/_MANUEL_)      OK
* unan/abs_pday       OK
* unan/abs_work       OK
* unan/aide           OK
* unan/bureau         OK
* unan/exemple        OK
* unan/lib/module/  abs_pday  OK
                    abs_work  OK
                    bureau    OK
                    exemple   OK
                    mail      OK
                    page_cours  OK
                    quiz        OK
                    signup      OK
                    standalone  OK
                    start_pday/ mail          OK
                                starter_pday  ---
                    work        OK
* unan/lib/required/  abs_pday    OK

# Processus de travail

* Un nouveau jour-programme commence
* -> Envoyer le mail décrivant le programme du jour à l'user
      => ajouter B_MAIL_DEB au jour de days_overview
* <- User confirme son démarrage
      => ajouter B_CONF_DEB au jour de days_overview

* Calcul des points de l'auteur.
  S'ils sont suffisants, le jour-programme est marqué OK
    => ajouter B_FIN au jour de days_overview
* <- L'auteur peut forcer la fin du jour-programme
    => ajouter B_FORC_FIN au jour de days_overview
    => ajouter B_FIN au jour de days_overview
* Un mail est envoyé pour confirmer la fin du travail (si nécessaire) avec récapitulation de ce qui a été fait
    => ajouter B_MAIL_FIN au jour de days_overview

* Explication du développement en spirale => page cours

# Raccourci et id pour les pages de cours

Mettre au point un système d'identifiant absolus sous forme de pointeurs (handler) pour les pages de cours. Cela permettra de les modifier plus facilement en cas de besoin.

Il faut donc une MAP qui tienne à jour ça. C'est dans une table

    id          ID absolu
    handler     <l'id à utiliser>       introduction_structure
    path        Path de la page, dans   structure/introduction.html
                ./data/cnarration/
    type        Le type de la page      HTML ou ?


# AU PAIEMENT

* Expliquer que c'est déjà commencé, mais qu'on peut mettre en pause
* Demander le rythme choisi
* Demander le support final (livre, film, etc.)
* Expliquer comment ça fonctionne, comment on travaille
* Envoi un mail à l'administration
* Envoi un long mail explicatif à l'user pour tout lui expliquer (ou faire un PDF ?)
* Faire signer un contrat à l'user ? Engagement à aller jusqu'au bout de son projet, sinon il paie une taxe :-).



# Reprendre :

La phrase de présentation qui dit "le pari de ce module est simple etc."

La mettre dans la présentation générale du programme.

# Faire une bande logo presque invisible

À part sur la toute première page d'accueil ou lorsque l'utilisateur n'est pas identifié (oui), mettre la bande de logo en presque invisible, n'apparaissant que lorsque l'utilisateur la survole avec sa souris.

    section#header

# Parler d'organisation
------------------------

Peut-être déjà dans la présentation du programme, parler de la difficulté d'organisation du travail pour développer une histoire et dire que le programme fait acquérir une méthode efficace et reproductible à tout projet.


* Pouvoir faire référence à un travail dans un travail.
  Il faut fonctionner avec des balises.
  Cela peut arriver assez souvent, lorsque l'on dit de repartir d'un document précédent pour élaborer un nouveau document selon le principe du développement en spirale.

  Noter qu'une propriété tient aussi ça à jour, en faisant directement référence à un autre travail.

# Développement en spirale

Bien expliquer le fait que le développement sera un développement en spirale au cours de ce programme.

Mettre ça dans une section qui parlerait de la méthode de développement utilisée.

Parler aussi dans cette partie de l'organisation du travail (voir la note plus haut).
