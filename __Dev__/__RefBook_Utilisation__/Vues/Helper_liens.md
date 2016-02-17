# Helper de liens

* [Introduction](#introductionhelperliens)
* [Liens RestSite par défaut](#lienspardefautsrestsite)
* [Liens propres à l'application](#liensproprealapplication)
* [Liens pour éditer des fichiers dans un éditeur](#liendeditiondefichier)
  * [Choix de l'éditeur par défaut](#choixediteurpardefaut)


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


<a name='liendeditiondefichier'></a>

## Liens pour éditer des fichiers dans un éditeur

    lien.edit_file "path/to/file"

Si on veut aller à un numéro de ligne précis :

    lien.edit_file "path/to/file", {line: <numéro de ligne>}

Par défaut, le fichier s'ouvrira dans l'[éditeur par défaut](#choixediteurpardefaut). Pour ouvrir le fichier dans un autre éditeur que l'éditeur par défaut, utiliser :

    lien.edit_file "path/to/file", {editor: <:atom | :textmate>}

Par défaut, le lien aura le titre “Ouvrir”. Pour mettre un titre propre utiliser :

    lien.edit_file "path/to/file.erb", {titre: "Mon titre"}
    
On peut bien sûr ajouter aux `options` toutes les valeurs pour la balise finale.

<a name='choixediteurpardefaut'></a>

### Choix de l'éditeur par défaut

Dans le fichier config.rb, définir :

    site.default_editor

Noter que pour ouvrir le fichier dans Atom, à ce jour (2016) il faut utiliser le script se trouvant à l'adresse [https://github.com/WizardOfOgz/atom-handler](https://github.com/WizardOfOgz/atom-handler).
