# Gestion des erreurs

* [Produire une erreur fatale](#produireuneerreurfatale)
* [Produire une erreur non fatale](#produireerrornonfatale)



<a name='produireuneerreurfatale'></a>

## Produire une erreur fatale

En utilisant `raise` sans spécifier d'erreur, on produit une erreur fatale qui conduit à l'affichage d'une page vierge (hors gabarit) contenant le message d'erreur.

Pour produire une erreur non fatale, c'est-à-dire apparaissant dans le gabarit du site, cf. [Produire une erreur non fatale](#produireerrornonfatale)

<a name='produireerrornonfatale'></a>

## Produire une erreur non fatale

Pour produire une erreur non fatale, c'est-à-dire s'affichant dans une page "normale" du site, il faut utiliser la tournure :

    raise NonFatalError, "le message d'erreur"
    
