# Gestion des scènes

* [Timeline des scènes](#timelinedescenes)
  * [Fabrication de la Timeline des scènes](#fabricationtimelinesceneapartirdefichier)
  * [Exemple de code complet pour la construction de la Timeline des scènes](#exempledecodecompletconstructiontimelinescenes)
* [Balises scènes et scénier](#balisesscenesetscenier)

<a name='timelinedescenes'></a>

## Timeline des scènes

La “Timeline des scènes” est un système permettant de visualiser les scènes et leur emplacement dans le film de façon très pratique. C'est une règle qui s'affiche quand on clique sur une scène ou un groupe de scène (un `<a>` qui appelle la méthode `Scenes.show`), met en exergue l'emplacement de la scène dans le film et affiche son résumé (dans un synopsis vertical comportant le résumé de toutes les scènes).

Pour pouvoir fonctionner, cette timeline des scènes a besoin de&nbsp;:

* un fichier comportant tout le code de la règle, avec en autre :
  * la timeline horizontale des scènes (où chaque scène est représentée par un rectangle de couleur),
  * la timeline verticale des scènes (leur résumé),
  * une boite de navigation de sélection pour passer d'une scène à l'autre lorsque plusieurs scènes sont sélectionnées,
  * un bouton de fermeture.

Ce fichier doit impérativement se trouver à la racine du dossier de l'analyse.

* Ensuite, l'analyse a besoin du fichier `show.js` (`./objet/analyse/show.js`) qui définit l'objet `Scenes` qui gère toutes les méthodes nécessaires à la Timeline.
* Ensuite, l'analyse a besoin du fichier `show.css` (`./objet/analyse/show.css`) qui définit tous les styles CSS indispensables à l'affichage correct des analyses.

<a name='fabricationtimelinesceneapartirdefichier'></a>

### Fabrication de la Timeline des scènes

Résumé rapide du code à inscrire&nbsp;:

    require './objet/analyse/lib/module/timeline_scenes/main.rb
    FilmAnalyse.build_timeline_scenes(
        data_scenes: <données des scènes (cf. ci-dessous),
        path:        <path du fichier à construire à partir de la racine>
        OU
        folder:       <path/du/dossier/pour/fichier_a_construire.htm>
      )

Voir aussi l'[exemple de code complet](#exempledecodecompletconstructiontimelinescenes) ci-dessous.

La [timeline des scènes](#timelinedescenes) peut se fabriquer à partir d'un `Array` de données contenant toutes les scènes à inscrire. On le passe à la méthode `FilmAnalyse.build_timeline_scenes` avec la propriété `:data_scenes`.

Ce `array` doit contenir des `Hash` qui définissent au minimum&nbsp;:

    :resume         Le résumé de la scène
    :numero         Le numéro de la scène
    :time           Le temps de la scène en secondes

    :horloge        Le temps peut être aussi fourni comme une horloge qui
                    sera transformée en temps.

Le DERNIER TEMPS doit être celui de la fin. Cette dernière donnée ne sera pas comptée comme une scène si elle ne contient pas de résumé.

<a name='exempledecodecompletconstructiontimelinescenes'></a>

### Exemple de code complet pour la construction de la Timeline des scènes


        # Pour que le module puisse être appelé dans Atom ou dans
        # TextMate, on se place toujours à la racine du site de la
        # boite à outils.
        ROOT_MAC_PHIL = '/Users/philippeperret/Sites/WriterToolbox'
        Dir.chdir(ROOT_MAC_PHIL) do

          # On indique ici le dossier de l'analyse. La timeline des
          # scènes est construite à la racine de ce dossier.
          folder_analyse = './data/analyse/film_MYE/21Grams2003'

          # On devra indiquer à la méthode de construction le path du
          # fichier final. Noter qu'on peut aussi bien passer le dossier
          # à l'aide de la propriété `:folder`
          path_timeline_film = File.join(folder_analyse, 'timeline_scenes.htm')


          # On récupère le module qui va répondre à la méthode-propriété
          # `data_scenes` qui contient toutes les données des cènes
          require File.join(folder_analyse, 'divers', 'data-scenes', 'data_scenes.rb')

          # On récupère le module de construction de la timeline des scènes
          require './objet/analyse/lib/module/timeline_scenes/main'

          # On appelle la méthode de construction
          FilmAnalyse.build_timeline_scenes(
            data_scenes:  data_scenes,
            path:         path_timeline_film
            # OU
            folder:       folder_analyse
          )
        end


<a name='balisesscenesetscenier'></a>

## Balises scènes et scénier

On peut utiliser des balises de la forme `SCENE[numéro|libelle|classe_css]` pour faire référence à des scènes dans un scénier.

Dès que l'affichage détecte un fichier comportant une telle balise, il charge les modules nécessaires pour la gestion de ces scènes. À savoir :

* le module javascript définissant l'objet `Scenes` (en fait, pour le moment, cet objet est toujours chargé puisqu'on le trouve dans `show.js`, un module toujours chargé à l'affichage de l'analyse par `show.(e)rb`),
* le scénier contenant les scènes
