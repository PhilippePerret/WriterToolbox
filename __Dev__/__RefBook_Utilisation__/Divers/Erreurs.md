# Gestion des erreurs

* [Produire une erreur fatale](#produireuneerreurfatale)
* [Produire une erreur non fatale](#produireerrornonfatale)
* [Écrire une erreur dans la page](#ecrireuneerreurdanslapage)


<a name='produireuneerreurfatale'></a>

## Produire une erreur fatale

En utilisant `raise` sans spécifier d'erreur, on produit une erreur fatale qui conduit à l'affichage d'une page vierge (hors gabarit) contenant le message d'erreur.

Pour produire une erreur non fatale, c'est-à-dire apparaissant dans le gabarit du site, cf. [Produire une erreur non fatale](#produireerrornonfatale)

<a name='produireerrornonfatale'></a>

## Produire une erreur non fatale

Pour produire une erreur non fatale, c'est-à-dire s'affichant dans une page "normale" du site, il faut utiliser la tournure :

    raise NonFatalError, "le message d'erreur"

<a name='ecrireuneerreurdanslapage'></a>

## Écrire une erreur dans la page

Écrire une erreur dans la page permet de ne pas vraiment générer d'erreur, par exemple l'analyseur de liens (LINKS ANALYZER) ne les verra pas. Typiquement, c'est la fonctionnalité utilisé quand un user non identifié essaie de rejoindre une page qui nécessite d'être identifié et qu'il est renvoyé vers le formulaire d'identification. Ce formulaire d'identification affiche l'erreur spécifique.

Définition du message d'erreur à mettre dans la page :

    page.error_in_page "<le message d'erreur à écrire>"

Pour incruster le message d'erreur dans la page, mettre à l'endroit voulu dans le code :

    <%= page.error_in_page %>

Noter que ce message sera mis dans un `div` de class css `error_in_page`.
