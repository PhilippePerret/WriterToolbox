# Helper de liens

* [Introduction](#introductionhelperliens)
* [Liens RestSite par défaut](#lienspardefautsrestsite)
* [Liens propres à l'application](#liensproprealapplication)

<a name='introductionhelperliens'></a>

## Introduction

On utilise la class `Lien` (singleton) pour obtenir tous les liens de l'application et de RestSite, par le biais de son instance `lien`.

Par exemple, pour obtenir un lien vers l'inscription :

    Pour vous <%= lien.signup "inscrire" %> sur le site.

<a name='lienspardefautsrestsite'></a>

## Liens RestSite par défaut

Toute application `RestSite` hérite des liens :

    lien.signup   # => lien pour s'inscrire
    lien.signin   # => lien conduisant au formulaire d'identification
    lien.subscribe  # => lien conduisant au formulaire d'abonnement, si
                    #    le site fonctionne par abonnement

<a name='liensproprealapplication'></a>

## Liens propres à l'application

On peut créer tous les liens propres à l'application dans le fichier :

    ./lib/handy/liens.rb

Un lien se construit très simplement par :

    class Lien

      def <nom du lien> titre = <titre défaut>, options = nil
        build <route>, titre, options
      end

      ...

    end

Par exemple :

    class lien

      def livres titre = "bibliotheque", options = nil
        build "livre/list", titre, options
      end

Dans le texte, il suffira alors d'utiliser ce lien de cette façon :

      Si vous voulez voir <%= lien.livres "tous mes livres" %> je vous
      invite à rejoindre ma <%= lien.livres "bibliothèque" %>.
