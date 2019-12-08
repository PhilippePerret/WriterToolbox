# Helper de liens

* [Introduction](#introductionhelperliens)
* [Liens de forme route](#liendeformeroute)
* [Liens d'aide et d'information (?)](#liendinformation)
* [Liens avec flèche et cadre](#lienavecflecheetcadre)
* [Boutons avant/après uniformisés](#boutonavantapres)
* [Liens RestSite par défaut](#lienspardefautsrestsite)
* [Liens propres à l'application](#liensproprealapplication)
* [Liens pour éditer des fichiers dans un éditeur](#liendeditiondefichier)
  * [Choix de l'éditeur par défaut](#choixediteurpardefaut)


<a name='introductionhelperliens'></a>

## Introduction

On utilise la class `Lien` (singleton) pour obtenir tous les liens de l'application et de RestSite, par le biais de son instance `lien`.

Par exemple, pour obtenir un lien vers l'inscription :

    Pour vous <%= lien.signup "inscrire" %> sur le site.

<a name='liendeformeroute'></a>

## Liens de forme *route*

@syntaxe

        lien.route <titre>, <route>, <options>

@exemple

        lien.route("Accueil", "site/home", {distant: true})

@produit

*(L'url réelle — scenariopole.fr — a été volontairement raccourcie pour l'exemple)*

    #   Si lien.output_format = :html (défaut)
    #   => <a href='http://wwww.boa.fr/site/home'
              target='_blank'>Accueil</a>

    #       Si lien.output_format = :markdown
    #   => [Accueil](http://www.boa.fr/site/home){:target='_blank'}

    #   Si lien.output_format = :latex
    #   (pour le moment)
    #   => 'Accueil'

La méthode est souple et peut s'appeler aussi avec :

        lien.route <route>

        lien.route <route>, <options>


<a name='liendinformation'></a>

## Liens d'aide et d'information (?)

Les liens d'information (qui doivent obligatoirement renvoyer à un fichier d'aide), avec une image point d'interrogation, peuvent s'obtenir par :

    <%= lien.information(12) %>
    <%= lien.aide(12) %>
    # Produira le lien vers le fichier d'aide 12 avec l'image
    # du point d'interrogation

On peut ajouter des options qui seront ajoutées à la balise :

    <%= lien.information(12, {float: right})

<a name='boutonavantapres'></a>

## Boutons avant/après uniformisés

On trouve par exemple ces boutons dans les pages Narration ainsi que dans le panneau permettant de lire tous les commentaires.

    lien.bouton_backward href: <href/route>
    lien.bouton_forward href: <href/route>

Alias :

    lien.backward_button
    lien.forward_button

Leur aspect peut être redéfini dans :

    ./lib/app/handy/liens.rb


<a name="lienspardefautsrestsite"></a>

## Liens RestSite par défaut

Toute application `RestSite` hérite des liens :

    lien.signup     # => lien pour s inscrire
    lien.signin     # => lien conduisant au formulaire d identification
    lien.subscribe  # => lien conduisant au formulaire d abonnement, si
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

      def livres titre = 'bibliotheque', options = nil
        build 'livre/list', titre, options
      end

Dans le texte, il suffira alors d'utiliser ce lien de cette façon :

      Si vous voulez voir <%= lien.livres 'tous mes livres' %> je vous
      invite à rejoindre ma <%= lien.livres 'bibliothèque' %>.


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

<a name='lienavecflecheetcadre'></a>

## Liens avec flèche et cadre

Pour obtenir une flèche et un cadre autour du lien, il suffit d'ajouter le `type: :arrow_cadre` aux options envoyés à un lien. Par exemple :

~~~ruby

    lien.subscribe("S’ABONNER", type: :arrow_cadre)

~~~

Sinon, pour un lien inconnu, il suffit d'utiliser la méthode générique :

~~~ruby

    lien.build( <route>, <titre>, {type: :arrow_cadre} )

~~~
