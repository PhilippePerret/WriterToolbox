# Placer le texte :

Écrire une histoire plus personnelle et plus passionnée. Ou écrire avec passion une écrire plus passionnée et plus personnelle
Éviter les sentiers battus et les histoires trop prévisibles : penser au contraire (le Principe du contraire <= principe créateur de haut niveau)


# Inscription de l'user au site quand il vient pour payer

Certains liens conduisent directement à la route `unan/paiement` même lorsque l'user n'est pas encore inscrit au site. Il faut dans ce cas procéder d'abord à leur inscription puis ensuite leur reproposer le formulaire de paiement.

=> Possibilité d'enregistrer une route à suivre après l'inscription (`route_to_follow`)

# Cas spéciaux

## User déjà abonné s'inscrivant au programme 1An1Script

Pour que l'user ne paye pas son abonnement et en plus son inscription au programme, on vérifie sa date de paiement.

Si l'utilisateur s'est abonné au site moins de 9 mois auparavant, on lui retire l'abonnement de l'inscription au programme. Sinon (+ de 9 mois), on le fait payer l'abonnement entier, sinon ce serait une arnaque pour ne pas payer son abonnement.
