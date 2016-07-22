# Quiz

* [Éditer les données du quiz](#affichageduformulaireduquizadmin)

L'idée serait de faire un module 'quiz' qui permette de faire n'importe quel type de questionnaire (uniforme sur le site).

On peut se servir du module qui est déjà employé par le programme UN AN UN SCRIPT ou repartir d'une base nouvelle pour justement améliorer le fonctionnement.

## REQUIS

* Une table pour enregistrer les données des questions et des questionnaires
* Une table pour enregistrer les résultats
* Un module administratif pour créer le questionnaire
* Un module helper pour fabriquer le questionnaire à afficher
* Un module pour afficher le questionnaire, avec ou sans les résultats de l'utilisateur
* Un module pour calculer le résultat du questionnaire. On enregistre les résultats si l'user est connu du site.


## Fonctionnement

Le module appelant doit définir la base de données qui sera employée pour gérer le questionnaire ou l'ensemble de questionnaire.

Il le fait en créant un module définissant :

    class Quiz


      # Le suffixe de la base qui contient tout.
      # Le nom exact dans MySQL dépendra de l'application. Pour le
      # BOA ce sera `boite-a-outils_quiz_biblio` (quiz est automatiquement
      # ajouté pour éviter tout conflit de nom)
      def suffix_base
        @suffix_base ||= :biblio
      end

    end

La base contiendra :

* La définition des questionnaires dans la table 'quiz'. Il peut y avoir plusieurs questionnaires, autant qu'on veut, dans la table quiz.
* La définition de toutes les questions dans la tables 'questions'
* Tous les résultats dans la table 'resultats'

<a name='affichageduformulaireduquizadmin'></a>

## Éditer les données du quiz

Pour éditer les données du quiz, si toutes les données sont définies, il suffit d'ajouter dans la vue d'édition :

        <%= ::Quiz.new.form(action: 'objet/vue') %>

Le formulaire d'édition aura l'id `edition_quiz` mais on peut en définir un autre en définissant `id` dans les attributs dans la méthode `form` ci-dessus.
