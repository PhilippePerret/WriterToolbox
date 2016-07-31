# Les Routes


* [Introduction](#introductionauxroutes)
* [La Route courante](#routecourante)
* [Précédente route suivie](#precedenteroutesuivie)
* [Tous les exemples possibles](#touslesexemples)
* [Classe de l'objet](#classedelobjet)
* [Utilisation des contextes](#utilisationdescontexte)


<a name='introductionauxroutes'></a>

## Introduction



Les application RestSite 2.0 fonctionnent essentiellement par route sous forme d'API :

    <objet>/<méthode de classe>

ou :

    <objet>/<objet id>/<méthode d'instance>

Par exemple, pour afficher le profil de l'utilisateur 12 :

    user/12/profil

<a name='routecourante'></a>

## La Route courante

Elle s'obtient par :

    site.current_route

Noter que c'est une instance de `SiteHtml::Route`. Mais on peut utiliser :

    "#{site.current_route}"

grâce à la méthode `to_str` qui est un alias de :

    site.current_route.route

On peut obtenir la route courante avec le contexte par l'handy méthode :

    current_route ou route_courante

Noter que cette méthode pratique a l'avantage de toujours retourner une valeur, même lorsque `site.current_route` est nil.

<a name='precedenteroutesuivie'></a>

## Précédente route suivie

Quelquefois, pour revenir à une page précédente, on doit faire référence à la route précédente. Pour y accéder, on utilise :

    site.route.last

<a name='touslesexemples'></a>

## Tous les exemples possibles

Pour simplifier la compréhension et le développement, on présente tous les exemples de route possible avec leurs différentes utilisations

### Méthode de classe simple

### Méthode de classe en contexte

On a par exemple une bibliothèque (contexte) qui contient des livres, et on veut afficher la liste des livres

La route sera :

    livre/list?in=bibliotheque

La classe `Bibliotheque` devra être définie dans :

    # in ./objet/bibliotheque/lib/required/class.rb ("class.rb" ou autre nom)
    class Bibliotheque
      ...
    end

La classe `Bibliotheque::Livre` devra être définie :

    # Soit dans ./objet/bibliotheque/lib/required/livre.rb
    # ("livre.rb" ou autre nom)
    # Soit dans ./objet/bibliotheque/livre/lib/required/class.rb
    # (ou autre nom)
    class Bibliotheque
      class Livre
        ...
      end
    end

Il faudra le fichier vue pour la liste des livres

    ./objet/bibliotheque/livre/list.erb # "list.erb" est impératif, ici

On pourra bien sûr définir une méthode `Bibliothque::Livre::list` dans un fichier :

    ./objet/bibliotheque/livre/list.rb # chargé automatiquement

Cette méthode pourra bien sûr être définie dans les fichiers (n'importe lequel) du dossier `./objet/bibliotheque/lib/required`


### Méthode de classe en contexte sans vue

On a par exemple un forum (contexte) qui contient des sujets (objet) et on veut détruire tous les sujets puis revenir à la liste des sujets (qui sera vide)

La méthode s'appelle `destroy_all`

On pourra bien entendu simplement la définir dans un des fichiers du dossier :

    ./objet/forum/lib/required

ou :

    ./objet/forum/sujet/lib/required

Mais pour une procédure coomme celle-là, qui ne doit être utilisée que très rarement, il vaut mieux faire un fichier ruby de nom exact :

    ./objet/forum/sujet/destroy_all.rb

Dans ce fichier :

    # encoding: UTF-8
    class Forum
      class Sujet
        def self.destroy_all
          raise "Accès interdit" if user.grade < 8 # barrière sécurité
          ... ici la destruction des sujets ...
        rescue Exception => e
          ... en cas d'erreur ...
        ensure
          # Et pour revenir à la liste des sujets même en cas
          # d'erreur :
          redirect_to "sujet/list?in=forum"
          # Note: on aurait pu faire aussi :
          # redirect_to :last_page ou :last_route
          # si on ne peut détruire la liste que depuis la liste des
          # sujets.
        end
      end
    end


### Méthode d'instance sans fichier

On est dans un forum, qui sera le contexte. On veut détruire un message de ce contexte, le message #12. Pour ce faire, on veut utiliser la route :

    message/12/destroy?in=forum

… qui doit nous ramener ensuite sur la page précédente, qui est la liste des messages.

Pour ce faire, on doit avoir un fichier :

    ./objet/forum/message/destroy.rb

Mais PAS de fichier :

    PAS DE : ./objet/forum/message/destroy.rb

Dans le fichier `./objet/forum/message/destroy.rb` on trouve le code :

    # encoding 'utf8'
    class Forum
      class Message
        def destroy
          table_message.delete(id)
          redirect_to :last_page
        end
      end
    end

### Instancier un autre objet que celui de la route/contexte

Le problème s'est posé avec les questionnaires, pour leur simulation en mode administration. La route était (c'est le programme UN AN) :

    quiz/<id>/simulation?in=unan_admin

En toute logique, la classe de l'instance de cette route doit être :

    UnanAdmin::Quiz

Or, nous voulons :

    Unan::QUiz

Dans ce cas, il faut utiliser le fait que l'instanciation se fait, dans la route, en premier lieu par la méthode de classe `get`. Ici `UnanAdmin::Quiz::get`. Et donc, on a fait :

    class UnanAmin
      class Quiz
        def self.get quiz_id
          Unan::Quiz::new(quiz_id)  # => Instance Unan::Quiz au lieu
                                    #    de UnanAdmin::Quiz
        end
      end
    end

Ce code est bien sûr mis dans un fichier `simulation.rb` à côté de `simulation.erb` pour être chargé avant que ne soit analysée la route.


<a name='classedelobjet'></a>

## Classe de l'objet


Par défaut, si l'objet :

    chose

… est utilisé, il doit renvoyer à une classe :

    Chose

… qui sera définie dans :

    ./objet/chose/un_fichier_ruby.rb

Mais il n'est pas indispensable que cette classe soit définie.

Par exemple, une simple vue peut être appelée, sans aucune définition de classe, par :

    chosesansclasse/savue

… si le fichier suivant existe, c'est lui qui sera affiché :

    ./objet/chosesansclasse/savue.erb

<a name='utilisationdescontexte'></a>

## Utilisation des contextes

Les “contextes” peuvent modifier le comporter des routes. Ci-dessus, il s'agissait d'objet “direct” dans le sens où l'objet défini dans la route était celui défini dans le dossier `objet`.

Mais dans les cas plus complexe où un objet peut avoir plusieurs sous-objet, il est intéressant de définir un contexte. Dans ce cas, toutes les routes seront analysées par rapport à ce contexte.

Imaginons un forum. `Forum` est l'objet (et donc la classe) principal. Il définit un dossier `./objet/forum`. Mais ce forum possède des sous-objets qui sont :

* Les messages
* Les sujets

Dans ce cas, on peut utiliser les routes :

    message/12/edit?in=forum

Ou :

    sujet/24/destroy?in=forum

Pour plus de détail, voir le fichier Objets.md.
