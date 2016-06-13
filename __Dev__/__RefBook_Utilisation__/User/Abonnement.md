# Abonnement

* [Boutons d'abonnement](#boutonabonnement)
<a name='boutonabonnement'></a>

## Boutons d'abonnement

On peut obtenir plusieurs boutons d'abonnement avec la classe singleton `Lien` :

    <%= lien.bouton_subscribe %>

Par défaut, le tarif est affiché. Pour ne pas le mettre :

    lien.bouton_subscribe(tarif: false)
