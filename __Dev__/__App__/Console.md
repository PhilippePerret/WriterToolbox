# Utilisation de la console

* [Description](#descriptionconsoleapplication)
* [Implémentation d'une commande application](#implementationdunecommande)


<a name='descriptionconsoleapplication'></a>

## Description


La console peut permettre de gérer plus efficacement et plus facilement l'application RestSite.

Par exemple simplement pour pouvoir se rendre dans une partie spécifique, appelons-là “Corridor” en tapant simplement :

    > goto corridor

    ou

    > aller corridor

<a name='implementationdunecommande'></a>

## Implémentation d'une commande application

* [Syntaxe de la commande](#definitionsyntaxedelacommande)
* [Interprétation de la commande](#interpretationdelacommande)
* [Appel d'une méthode d'exécution propre](#appeldunemethodedexecution)
* [Messages et résultat retournés par la méthode](#messagesretournesparlamethode)

Implémenter une commande nécessite plusieurs choses :

* définir la commande, la forme qu'elle peut avoir, ses variables, etc. ([détail](#definitionsyntaxedelacommande))
* que la commande puisse être interprétée ([détail](#interpretationdelacommande))
* que la commande appelle une méthode précise ([détail](#appeldunemethodedexecution))
* que cette méthode produise un résultat et retourne un ou des messages (* [détail](#messagesretournesparlamethode)
).

Nous allons voir ces quatre étapes ci-dessous, en prenant l'exemple d'une commande qui permettrait d'obtenir des balises hypertextuelles pour afficher un film ou un mot de dictionnaire.

<a name='definitionsyntaxedelacommande'></a>

### Syntaxe de la commande

La commande peut avoir cette forme :

    Commande "telle quelle" (sans variable)     check synchro
    Commande avec dernier mot variable          goto <ici>
    Commande répondant à une expression
    régulière.                                  balise (film|mot) <string>
    Commande de type `get... of...`             get mail of user 12

Notre commande pour obtenir une balise pour un film ou un mot sera sous forme d'expression régulière. On sait que la commande commence par :

    ^balise

… qu'elle peut être ensuite 'film' ou 'mot'

    ^balise (film|mot)

… et que la suite jusqu'au bout sera la référence au film ou au mot. L'expresionn régulière complète sera donc :

    /^balise (film|mot) (.\*)$/
    # Note : La balance placée avant l'étoile ne doit pas être
    # mise, elle est seulement là pour l'affichage markdown

<a name="interpretationdelacommande"></a>

### Interprétation de la commande

L'interprétation de la commande doit être implémentée dans le fichier :

    ./lib/app/console/execution_commandes.rb

C'est ce fichier qui exécute toutes les commandes reçues et c'est dans ce fichier qu'il faut implémenter le traitement **en fonction de la forme/syntaxe de la requête**.


Attention, les méthodes systèmes propres à RestSite sont implémentées dans le fichier :

    ./lib/deep/console/execution.rb

… qui fait appel au fichier des exécutions propres à l'application.

<a name='appeldunemethodedexecution'></a>

### Appel d'une méthode d'exécution propre

Dans le fichier précédent permettant de “catcher” la commande, il faut que la condition `when` appelle une méthode propre plutôt que d'implémenter le code sous ce when.

Pour ce faire, on implémente une méthode dans un fichier général d'objet. Je m'explique :

* Si l'objet touché par la commande s'appelle par exemple "dicofilm", on crée un fichier appelé par exemple “methodes.rb” dans :

    ./lib/app/console/dicofilm/methodes.rb

Pour appeler ce fichier, on aura juste à faire :

    when /ma commande catchée/
      console.require 'dicofilm'  # <- charge tout le dossier
      execute_ma_methode line     # <- méthode de traitement de la commande
                                  # Noter que ça doit être `line` ou autre
                                  # chose qui doit être envoyé, suivant la
                                  # méthode.

Il suffit alors d'implémenter la méthode `execute_ma_methode` (qui peut avoir bien sûr n'importe quel nom) dans le fichier `dicofilm/methodes.rb`.

Cette méthode doit être définie pour `SiteHtml::Admin::Console` (singleton) donc le fichier doit être quelque chose comme :

    class SiteHtml
    class Admin
    class Console

      def execute_ma_methode line
        ... traitement ici ...
      end

      ...

<a name='messagesretournesparlamethode'></a>

## Messages et résultat retournés par la méthode

La méthode a deux moyens de retourner des messages.

1. Le texte retourné par la méthode s'affichera dans la console, en commentaire, sous la ligne ayant produit le résultat. Retourner le code `""` pour que rien ne soit affiché dans la console.
2. L'utilisation de la méthode `sub_log("MESSAGE")` permet de définir le texte à afficher sous la console, dans le cadre grisâtre de retour. On peut appeler la méthode autant de fois que nécessaire, les différents messages s'ajoutent les uns aux autres.
