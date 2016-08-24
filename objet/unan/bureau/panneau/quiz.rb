# encoding: UTF-8

# Chargement des librairies générales du quiz
site.require_objet 'quiz'
# Chargement du module propre au quiz, qui va permettre
# notamment de construire les cartes
Unan::require_module 'quiz'

class Unan
class Bureau

  attr_accessor :current_quiz_output

  def missing_data
    @missing_data ||= begin
      nil # pour le moment
      # TODO Signaler des erreurs lorsque des questionnaires sont
      # en retard.
    end
  end

end #/Bureau
end #/Unan

# Pour lancer la sauvegarde des données du questionnaire
case param(:operation)
when 'bureau_save_quiz'

  # L'UnanQuiz (propre au programme)
  unanquiz_id = param(:unanquiz).to_i_inn
  unanquiz_id != nil || raise('Il faut définir l’ID du UnanQuiz dans les paramètres !')
  unanquiz = Unan::UnanQuiz.new(unanquiz_id)

  # Le Quiz (l'instance Quiz général, pour tout quiz)
  quiz_id = param(:quiz)[:id].to_i_inn
  quiz_id != nil || raise('Aucun questionnaire n’a été soumis…')
  quiz = Quiz.new(quiz_id, 'unan')

  awork_id = param(:awork).to_i_inn
  awork_id != nil || raise('Aucun travail absolu n’est associé à ce questionnaire. Impossible de le traiter.')
  awork = Unan::Program::AbsWork.new(awork_id)

  # TODO Les résultats sont enregistrés pour l'auteur dans une rangée
  # dont il faut récupérer l'ID pour pouvoir associer le quiz de cette
  # date (pday) avec cette rangée (dans le cas où plusieurs même quiz
  # sont effectués)
  # L'idéal serait de l'enregistrer dans le work correspondant à ce
  # awork (un work a été créé lorsque l'user marque que ce quiz a été
  # vu, on enregistre dans ses données la rangée ou la référence aux
  # résultats de ce quiz)
  # NOTE Il ne faut le faire que si l'évaluation a été possible

  # TODO Traiter le cas d'un questionnaire qu'il ne faut pas enregistrer,
  # comme celui de l'évaluation de projet.
  # Comment l'indiquer ?
  # Comment ne pas l'enregistrer ? (en fait, je crois qu'il faut le laisser
  # l'enregistrer mais qu'il faut ensuite détruire la donnée ici)

  # bureau.current_quiz_output = unanquiz.output(evaluate: true)
  bureau.current_quiz_output = awork.as_card(evaluate: true)

when 'quiz_reuse'

end
