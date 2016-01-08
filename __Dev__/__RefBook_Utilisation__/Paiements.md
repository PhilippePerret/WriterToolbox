# Paiements

* [Récapitulatif pour l'implémentation du paiement](#recapitulatifdeimplementation)
* [Implémentation de la précédure de paiement](#implementationprocedurepaiement)
* [Configuation du paiement (données générales)](#configurationdesdonneesgenerales)
* [Définir le tarif du site](#definirletarifdusite)
* [Fichier de lancement de la transaction (paiement.rb)](#fichierdelancementdetransaction)
* Les vues
  * [Formulaire propre à une section](#formulairepropreaunpaiement)
  * [Vue principale du paiement](#vueprincipaledupaiement)
  * [Vue propre à la validation du paiement](#vueproprequandok)
  * [Vue propre au renoncement du paiement](#vueproprequandcancel)
  * [Vue d'erreur propre](#vueerreurpropre)
* [Test du paiement](#testdufonctionnement)

`RestSite 2.0` gère entièrement les paiements par PayPal.


<a name='recapitulatifdeimplementation'></a>

## Récapitulatif pour l'implémentation du paiement

Dans tous les cas, il faut [créer le fichier de données PayPal](#configurationdesdonneesgenerales)

### Pour gérer l'abonnement au site

Il suffit de définir le tarif dans le fichier de configuration

    # in ./objet/site/config.rb
    ...
    site.tarif = 5.20
    ...

… puis de mettre quelque part un lien vers la route `user/paiement`. Par exemple :

    <a href="user/paiement">Vous abonner au site</a>

### Pour gérer le paiement sur le site dans un contexte donné, il faut :

* [Créer la vue principale `paiement.erb`](#vueprincipaledupaiement) à la racine du dossier du contexte.
* [Créer le fichier de transaction `paiement.rb`)](#fichierdelancementdetransaction)
* Créer un dossier `paiement` à la racine du contexte pour y mettre les fichiers propres
* [OPTIONNEL] [Créer le fichier `paiement/form.erb`](#) si on veut un formulaire propre
* [Créer le fichier `paiement/on_ok.erb`](#vueproprequandok) définissant la vue partielle à afficher (dans `paiement.erb`) en cas de succès du paiement
* [OPTIONNEL] [Créer le fichier `paiement/on_cancel.erb`](#vueproprequandcancel) définissant la vue partielle à afficher (dans `paiement.erb`) quand le paiement est annulé ou refusé.
* [OPTIONNEL] [Créer le fichier `paiement/on_error.erb`](#vueerreurpropre) définissant la vue partielle à afficher (dans `paiement.erb`) quand une erreur survient.

Noter que les vue partielle s'affichent dans la vue `./objet/<context>/paiement.erb` si le code suivant est implémenté dans cette vue :

    <%= site.paiement.output %>

Voilà une vision complète avec tous les fichiers, dans un contexte qui s'appelle `moncontexte` :

    ./objet/moncontexte/  
                      paiement.erb      # vue principale
                      paiement.rb       # appelle make_transaction
                      paiement/
                            form.erb      # Formulaire propre
                            on_ok.erb     # partielle si OK
                            on_ok.rb      # du code à jouer si OK
                            on_cancel.erb # partielle si pas OK
                            on_error.erb  # partielle si erreur


<a name='configurationdesdonneesgenerales'></a>

## Configuation du paiement (données générales)

Il faut créer un fichier :

    ./data/secret/paypal.rb

(en considérant que le dossier `data/secret` NE DOIT PAS ÊTRE DÉPOSÉ sur Github si on possède un compte public)

Dans ce fichier définir toutes les données du compte :

    # encoding: UTF-8
    PAYPAL = {
      # Les COMPTES

      # LE COMPTE DE BAC À SABLE / TESTS
      sandbox_account: {
        username:   "<le pseudo quand bac à sable>",
        password:   "<le code secret quand bac à sable>",
        signature:  "< la signature quand bac à sable>",
        sandbox_id: "<Application ID pour le bac à sable>"
      },

      # LE COMPTE RÉEL
      live_account: {
        username:   "<le vrai pseudo>",
        password:   "<le vrai code secret>",
        signature:  "< la vraie signature>",
        merchand_id:  "<ID marchand>",
        live_app_id:  "<ID de l'application réelle>",
        app_name:     "<nom humain de l'application>"
      },

      # Pour faire des tests avec des utilisateurs fictifs
      # NOTE : Ces utilisateurs doivent être enregistrés sur PayPal
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

## Implémentation de la procédure de paiement

Avant d'implémenter une procédure de paiement, il faut [configurer le paiement pour le site](#configurationdesdonneesgenerales) en suivant la procédure ci-dessus.

Il suffit ensuite d'implémenter dans un fichier chargé à l'affichage de la section de paiement, par exemple le fichier `./objet/mon_espace/paiement.rb` si c'est la vue `./objet/mon_espace/paiement.erb` qui est appelée :

    # encoding: UTF-8
    app.require_optional 'paiement'
    site.paiement.make_transaction(<data transaction>)

`<data transaction>` doit définir :

    :montant

        {Float} Le montant à payer, en flottant

    :objet

        {String} Texte littéraire destiné à la facture de
        l'user (facture qui lui sera automatiquement
        envoyée après son paiement).

    :objet_id

        {String} Un code de 0 à 200 caractères pour la table
        des paiements, indiquant le type de paiement dont il
        s'agit.
        Par exemple, pour une inscription au site, si la donnée
        n'est pas modifiée dans `./objet/user/paiement.rb`, le
        code est "ABONNEMENT"

    :context

        {String} Le contexte dans lequel se fait le paiement, c'est
        à-dire la sous-section, si ce n'est pas le paiement du site
        lui-même (abonnement).
        Ce contexte est le dossier qui contient le fichier `paiement.erb`
        et le fichier `paiement.rb` ainsi que le dossier `paiement`
        qui contient tous les fichiers nécessaires.
        Par défaut, donc sans cette donnée, le contexte est 'user'

    :description

        {String} Texte littéraire destiné à l'user qui sera
        affiché au-dessus du bouton Paypal, pour informer de
        ce que sera l'opération. Il sera placé après le
        texte "au "<paiement/réglement etc.>

<a name='fichierdelancementdetransaction'></a>

## Fichier de lancement de la transaction (paiement.rb)

En parallèle du fichier `./objet/<context>/paiement.erb` qui est la base du paiement, on trouve le fichier `./objet/<context>/paiement.rb`, appelé juste avant, qui va appeler la transaction. Dans ce fichier, on doit faire un appel à `site.paiement.make_transaction(<data>)` pour lancer la transaction, quelle qu'elle soit (même les retours du site PayPal) :

    # Dans ./objet/<context>/paiement.rb
    site.paiement.make_transaction({
      montant:  9.55,
      objet_id: "FOURNITURE"
      etc.
      })

Pour les données de la transaction, cf. la [procédure de paiement](#implementationprocedurepaiement).

<a name='formulairepropreaunpaiement'></a>

## Formulaire propre à une section

Par défaut, c'est toujours le formulaire `./objet/user/paiement/form.erb` qui est utilisé pour le paiement. Il utilise un affichage standard avec un texte et un bouton PayPal pour payer.

Si l'on veut un formulaire propre pour une sous-partie, il suffit de créer le fichier `paiement/form.erb` dans le dossier de cette sous-partie (qu'on appelle "context" sur les RestSite).

Par exemple, pour le contexte `unan` défini dans :

    ./objet/unan

On peut définir :

    ./objet/unan/paiement/form.erb

… qui définira le formulaire propre à utiliser.

<a name='vueprincipaledupaiement'></a>

## Vue principale du paiement

La vue principale du paiement doit s'appeler `paiement.erb` et se trouver à la racine du contexte.

Par exemple, pour le contexte `unan` :

    ./objet/unan/paiement.erb

Pour obtenir les retours des transaction, il faut simplement écrire dans ce fichier :

    ...
    <%= site.paiement.output %>
    ...

Cela affichera dans un premier temps le formulaire, puis les confirmations de paiement, etc.


<a name='vueproprequandok'></a>

## Vue propre à la validation du paiement

Pour définir une vue propre à la confirmation du paiement (donc après un paiement réussi), il suffit de créer la vue :

    ./objet/<context>/paiement/on_ok.erb

<a name='vueproprequandcancel'></a>

## Vue propre au renoncement du paiement

De la même manière que ci-dessus, on peut créer une vue propre quand le paiement est annulé ou refusé en créant la vue :

    ./objet/<context>/paiement/on_cancel.erb

<a name='vueerreurpropre'></a>

## Vue d'erreur propre

On peut créer une vue d'erreur propre au paiement dans le context en créant le fichier :

    ./objet/<context>/paiement/on_error.erb

<a name='testdufonctionnement'></a>

## Test du paiement

Le test de paiement se fait dans la sandbox (bac à sable) de PayPal. Pour le moment, le réglage se fait simplement par le fait d'être OFFLINE (sandbox) ou ONLINE (mode live, réel).

Si on veut modifier ce comportement, il faut modifier la méthode `sandbox?` dans le fichier :

    
