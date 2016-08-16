# Les Objets

* [Définition préliminaire](#definitionpremiminaire)
* [Méthode `get`](#methodegetobligatoire)
* [Objets dans un contexte (sous-objets)](#objetsdansuncontexte)
* [Le dossier de l'objet](#ledossierdelobejt)

Voir aussi la partie très concrète avec de nombreux exemples dans [Tous les exemples possibles](Routes.html#touslesexemples).



<a name='definitionpremiminaire'></a>

## Définition préliminaire

Un “objet” est tout élément permettant de fabriquer une application, tout élément que va manipuler cette application. Les `Users` par exemple sont des objets. S'il y a un forum, le `Forum` est un objet, les `Messages` et les `Sujets` sont des objets.

Ces objets peuvent être “universels” (comme les Users) et n'ont donc pas besoin d'être définis dans une application RestSite 2.0.

D'autres sont propres à l'application est doivent être définis dans :

    ./objet/

Et particulièrement dans :

    ./objet/<nom minuscule objet>/lib/required

<a name='methodegetobligatoire'></a>

## Méthode `get` obligatoire

La méthode de classe `get` est pratique (mais pas obligaoire) pour fonctionner avec les instances par les routes. Elle doit retourner l'instance de la classe.

OBSOLÈTE : on doit abolument éviter la méthode get à présent, qui présente vraiment trop de problèmes pour très peu d'avantages.

Par exemple, si la route est `user/12/profil`, l'instance `SiteHtml::Route` de cette route va tenter d'appeler `User::get(12)` pour obtenir l'instance de l'user #12.

Noter que si la méthode `get` n'est pas définie, il faut obligatoirement que la méthode `initialize` existe et reçoive l'ID de l'objet en premier argument. Si la méthode peut recevoir d'autres arguments (comme les data en deuxième argument), alors il faut les mettre optionnels :

    def initialize id, data = nil, options = nil
      @id = id
      ...
    end


<a name='objetsdansuncontexte'></a>

## Objets dans un contexte (sous-objets)

Imaginons un `Forum` qui contient des `Sujets` et des `Messages`.

Dans ce cas, l'objet seul `Forum` ne permet pas de gérer l'ensemble des routes. On définit alors un contexte (`?context=<le contexte>`) qui va redéfinir la route.

Par exemple, la route :

    message/12/edit?in=forum

… signifie : jouer la route `message/12/edit` qui permet d'éditer le message 12 dans le contexte du forum.

Programmatiquement, cela signifie qu'il faut créer la classe :

    class Forum
      class Message
        ...
        def edit
          ...
        end
      end
    end

De la même manière, les vues doivent se trouver dans des sous-dossiers. Par exemple, la vue d'édition du message se trouvera dans :

    ./objet/forum/message/edit.erb

<a name='ledossierdelobejt'></a>

## Le dossier de l'objet

    <Objets>#folder
