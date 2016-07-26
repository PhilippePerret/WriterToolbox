# Divers à propos de l'user

* [Options de l'utilisateur](#optionsuser)
  * [Grade d'administration](#gradedadministration)
  * [Grade du forum](#gradeforumeuser)
  * [Confirmation du mail](#confirmationmail)
* [Autologin de l'utilisateur](#autologineuser)
* [Redirection après l'identification (login)](#redirectionapreslogin)
* [Opérations après identification](#operationsapreslidentification)
* [Destruction d'un utilisateur](#destructionuser)

<a name='optionsuser'></a>

## Options de l'utilisateur

Les `options` de l'utilisateur permettent de définir certaines données “bits” de l'utilisateur. Nous allons les détailler ci-dessous, voici un bref aperçu.

    BIT 1   Degré d'ADMINISTRATION

Cf. [Grade administration](#gradedadministration)

    BIT 2   Grade sur le forum

Cf. [Grade forum](#gradeforumeuser)

    BIT 3   Confirmation du mail

Cf. [Confirmation du mail](#confirmationmail)

<a name='gradedadministration'></a>

### Grade d'administration

Bit 1 des options. Comparaison par bit

    0 Simple utilisateur
    1 Administrateur de premier niveau
    2 Super-administrateur
    4 Grand manitou

<a name='gradeforumeuser'></a>

## Grade du forum

Si c'est un forum à haut degré de modération (avec n'importe qui ne pouvant pas s'y exprimer), le deuxième bit des options de l'user conserve la valeur.

Bit 2 des options. Valeur de 0 à 9, depuis le simple lecteur qui ne peut pas laisser de message jusqu'au modérateur qui a tout pouvoir.

Cf. le fichier ./lib/deep/deeper/required/User/constants.rb pour les valeurs que peut prendre ce deuxième caractère.


<a name='confirmationmail'></a>

## Confirmation du mail

Pour être tout à fait enregistré, l'utilisateur doit confirmer son mail en répondant au mail qui lui a été envoyé.

Cela met son BIT 3 à 1



<a name='autologineuser'></a>

## Autologin de l'utilisateur

On peut autologuer l'utilisateur en utilisant la méthode :

    User#autologin

Cette méthode ne peut bien entendu pas être appelée directement, elle doit l'être par le biais, par exemple, d'un ticket. Ce ticket peut avoir comme code :

    User.new(<user id>).autologin(route: 'route/afficher');flash(\"\#{user.pseudo}, je vous ai autologué.\")

Ce code autologuera l'user et lui affichera un message contenu son pseudo.


---------------------------------------------------------------------

<a name='redirectionapreslogin'></a>

## Redirection après l'identification (login)

Pour rediriger l'user quelque part après son identification au site RestSite, il suffit d'implémenter dans une extension de l'instance `User` la méthode `redirect_after_login`. C'est dans cette méthode qu'on peut par exemple tester des préférences ou un statut de l'user pour le rediriger vers la page adéquate à l'aide de `redirect_to`.

    class User
      ...
      def redirect_after_login
        ... test pour voir les préférences par exemple ...
        redirect_to <route en fonction des préférences>
      end
      ...
    end

Une autre solution, si l'identification est appelée par un lien, est d'envoyer la route suivante à la méthode `lien.signin` (qui conduit au formulaire d'identification) :

    <%=
      lien.signin "vous identifier", back_to: "la/route/suivante?in=context"
    %>

Si on doit reconduire à la route courante (une page qui nécessite une identification pour être complète), on peut utiliser ÷

    <%=
      lien.signin "vous identifier", back_to: current_route
    %>

<a name='operationsapreslidentification'></a>

## Opérations après identification

Pour définir les choses à faire, propres à l'application, après le login d'un user, il suffit d'implémenter la méthode :

    User#do_after_login

Cette méthode peut par exemple être définie dans un fichier :

    ./lib/app/required/user/do_after_login.rb

    # in ./lib/app/required/user/do_after_login.rb
    # encoding: UTF-8
    class User
      def do_after_login
        ... code ...
      end
    end

<a name='destructionuser'></a>

## Destruction d'un utilisateur

La destruction d'un utilisateur se fait par la méthode `User#remove`. Mais cette méthode ne fait que supprimer la donnée de l'user dans la table des users (`users.db`).

Pour appliquer une destruction particulière à l'application, il suffit d'implémenter la méthode :

    User#app_remove

Cette méthode sera automatiquement appelée AVANT la destruction de l'user dans la table des users.
