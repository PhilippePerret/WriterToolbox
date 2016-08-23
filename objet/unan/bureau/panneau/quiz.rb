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
  quiz_id = param(:quiz)[:id].to_i_inn
  quiz_id != nil || raise('Aucun questionnaire n’a été soumis…')
  # quiz = Unan::Quiz::get(quiz_id)
  quiz = Quiz.new(quiz_id, 'unan')

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

  quiz.evaluate
  bureau.current_quiz_output = quiz.output

  # bureau.current_quiz_output =
  #   if quiz.evaluate_and_save( awork_id: awork_id, awork_pday: awork_pday )
  #     quiz.commented_output
  #   else
  #     # Étudier et construire le retour en fonction du questionnaire
  #     # qu'il ait été rempli correctement ou non.
  #     awork = Unan::Program::AbsWork.new(awork_id, {pday: awork_pday})
  #     quiz.as_card(awork) + quiz.code_for_regle_reponses
  #   end
when 'quiz_reuse'
  # # L'auteur passe par ici quand il veut recommencer un quiz
  # # réutilisable (multi?). Pour pouvoir le réutiliser, on
  # # doit le remettre en questionnaire à faire donc remettre
  # # le travail correspondant en route.
  # if param(:qru) == '1' && param(:qid) != nil
  #   qid = param(:qid).to_i
  #   # On doit s'assurer d'abord que ça n'est pas un questionnaire
  #   # normal avec l'auteur qui triche
  #   q = Unan::Quiz::get(qid)
  #   if q.multi?
  #     # => OK
  #     # Il faut remettre le travail de ce quiz dans la
  #     # liste des quiz courant de l'auteur
  #
  #     # Le travail propre à l'auteur et au questionnaire
  #     quiz_work     = q.work
  #     # Son identifiant, qu'on va ajouter aux listes des
  #     # travaux courants
  #     quiz_work_id  = quiz_work.id
  #   else
  #     error "Vous ne pouvez pas recommencer ce questionnaire, voyons…"
  #   end
  # else
  #   error "Vous ne pouvez pas exécuter cette opération…"
  # end
end
