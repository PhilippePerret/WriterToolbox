# Divers à propos de l'user

* [Options de l'utilisateur](#optionsuser)
  * [Grade d'administration](#gradedadministration)
  * [Grade du forum](#gradeforumeuser)
  * [Confirmation du mail](#confirmationmail)
* [Redirection après l'identification (login)](#redirectionapreslogin)
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

Cf. le fichier forum/user/constants.rb pour les valeurs que peut prendre ce deuxième caractère.


<a name='confirmationmail'></a>

## Confirmation du mail

Pour être tout à fait enregistré, l'utilisateur doit confirmer son mail en répondant au mail qui lui a été envoyé.

Cela met son BIT 3 à 1

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

<a name='destructionuser'></a>

## Destruction d'un utilisateur

La destruction d'un utilisateur se fait par la méthode `User#remove`. Mais cette méthode ne fait que supprimer la donnée de l'user dans la table des users (`users.db`).

Pour appliquer une destruction particulière à l'application, il suffit d'implémenter la méthode :

    User#app_remove

Cette méthode sera automatiquement appelée AVANT la destruction de l'user dans la table des users.
