# Autorisations

* [Autoriser l'accès à une page](#autoriseraccesunepage)

<a name='autoriseraccesunepage'></a>

## Autoriser l'accès à une page

On peut autoriser l'accès à une page en ajouter `authips=1` dans l'URL si l'IPs de l'utilisateur se trouve consignée dans le fichier `./data/secret/authorized_ips.rb`.

L'user ne sera pas identifié, mais il aura un accès complet à la page.

Cette procédure a été mise en place pour permettre à LINKS ANALYZER de tester toutes les pages Narration et Analyse en entier.
