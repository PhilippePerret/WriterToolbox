# encoding: UTF-8
=begin
  Module pour l'édition du quiz du scénodico
=end
class Scenodico
  class Quiz
    class << self

      # Retourne le formulaire d'édition du quiz pour le
      # scénodico. Ce questionnaire a l'identifiant 1 dans
      # la base `boite-a-outils_quiz_biblio` mais on pourrait
      # imaginer qu'il y a plusieurs niveaux de questionnaires.
      # Noter que cette base contient aussi d'autres questionnaires
      # à commencer par ceux sur les films.
      def form
        ::Quiz.new(1).form(action: 'scenodico/quiz_edit')
      end
    end #/<< self
  end #/Quiz
end #/Scenodico
