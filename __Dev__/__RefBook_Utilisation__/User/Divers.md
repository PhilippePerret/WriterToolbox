# Divers à propos de l'user

* [Redirection après l'identification (login)](#redirectionapreslogin)


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
