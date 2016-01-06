# Paiements

* [Implémentation de la précédure de paiement](#implementationprocedurepaiement)
* [Configuation du paiement (données générales)](#configurationdesdonneesgenerales)
* [Définir le tarif du site](#definirletarifdusite)
* [Test du paiement](#testdufonctionnement)

`RestSite 2.0` gère entièrement les paiements par PayPal.

<a name='configurationdesdonneesgenerales'></a>

## Configuation du paiement (données générales)

Il faut créer un fichier :

    ./data/secret/paypal.rb

(en considérant que le dossier `data/secret` n'est pas déposé sur Github si compte public)

Dans ce fichier définir toutes les données du compte ainsi que les URL nécessaires :

    # encoding: UTF-8
    PAYPAL = {
      # Les COMPTES
      sandbox_account: {
        username:   "<le pseudo quand bac à sable>",
        password:   "<le code secret quand bac à sable>",
        signature:  "< la signature quand bac à sable>",
        sandbox_id: "<Application ID pour le bac à sable>"
      },
      live_account: {
        username:   "<le vrai pseudo>",
        password:   "<le vrai code secret>",
        signature:  "< la vraie signature>",
        merchand_id:  "<ID marchand>",
        live_app_id:  "<ID de l'application réelle>",
        app_name:     "<nom humain de l'application>"
      },

      # Pour faire des tests avec des utilisateurs fictifs (qui doivent
      # être enregistrés sur Paypal)
      user_accounts: {
        <pseudo>: {
          username:   "<le pseudo>",
          email:      "<l'adresse mail>",
          password:   "<le mot de passe"
        }
        <pseudo>: {
          etc.
        }
      }
    }

Il faut également [définir le tarif du site](#definirletarifdusite).


<a name='definirletarifdusite'></a>

## Définir le tarif du site

Si le site possède un tarif unique d'abonnement, on peut le définir dans les configuration.

    # in ./objet/site/config.rb
    site.tarif = <{Fixnum} le tarif>

<a name='implementationprocedurepaiement'></a>

## Implémentation de la précédure de paiement

Avant d'implémenter une procédure de paiement, il faut [configurer le paiement pour le site](#configurationdesdonneesgenerales).

Il suffit ensuite d'implémenter dans un fichier chargé à l'affichage de la section de paiement :

    # encoding: UTF-8
    app.require_optional 'paiement'
    site.paiement.make_transaction(montant: <le montant>[,context:"in/sousdos"])

Noter que `context` permettra de faire des paiements dans des sous-rubriques. Par exemple, pour le site des outils de l'auteur, on a un paiement pour un abonnement à l'année à tout le site (c'est l'abonnement général, donc sans contexte) et un abonnement au programme “un an un script”. Dans ce dernier cas, pour distinguer l'un et l'autre, on modifie le contexte et le montant.

Dans la vue principale du paiement, qui doit s'appeler quelque chose comme `paiement.erb`, il faut simplement écrire :

    <%= site.paiement.output %>

… pour afficher ce qui doit l'être.

Pour définir un traitement de retour (OK ou CANCEL) propre, il faut redéfinir (surclasser) les méthodes `SiteHtml::Paiement#on_ok` et `SiteHtml::Paiement#on_cancel`. Mais normalement, ça n'est pas nécessaire, il suffit de définir la méthode `SiteHtml::Paiement#consigner_paiement` pour définir comment ce paiement sera enregistré (par exemple dans une table de paiements).

Pour définir une vue propre quand le paiement est effectué et confirmé :

TODO

Pour définir une vue propre quand le paiement est annulé :

TODO (une vue — partial — à définir, peut être ./objet/user/paiement_ok.erb)

Pour définir une vue propre pour le formulaire de paiement :

TODO (redéfinir la méthode site.paiement.formulaire_paiement)


* [Consignation du paiement](#consignationdupaiement)
<a name='consignationdupaiement'></a>

## Consignation du paiement

Pour pouvoir consigner le paiement et envoyer une confirmation à l'utilisateur, on implémente la méthode :

    class SiteHtml
      class Paiement
        def consigner_paiement

        end
      end
    end

Bien entendu, cette méthode doit être accessible (chargée) au moment du paiement (au moins en fin de processus).

Cette méthode peut utiliser toutes les informations en paramètres :

    param(:token)     # => Le token de l'opération de paiement
    param(:invoice)   # => Le numéro de facture paypal (= token)


<a name='testdufonctionnement'></a>

## Test du paiement
