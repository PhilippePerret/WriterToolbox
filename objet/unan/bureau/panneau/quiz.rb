# encoding: UTF-8
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
  quiz = Unan::Quiz::get(quiz_id)

  awork_id    = param(:quiz)[:awork_id].to_i
  awork_pday  = param(:quiz)[:awork_pday].to_i
  bureau.current_quiz_output =
    if quiz.evaluate_and_save( awork_id: awork_id, awork_pday: awork_pday )
      quiz.commented_out
    else
      # Étudier et construire le retour en fonction du questionnaire
      # qu'il ait été rempli correctement ou non.
      awork = Unan::Program::AbsWork.new(awork_id, {pday: awork_pday})
      quiz.as_card(awork) + quiz.code_for_regle_reponses
    end
when 'quiz_reuse'
  # L'auteur passe par ici quand il veut recommencer un quiz
  # réutilisable (multi?). Pour pouvoir le réutiliser, on
  # doit le remettre en questionnaire à faire donc remettre
  # le travail correspondant en route.
  if param(:qru) == '1' && param(:qid) != nil
    qid = param(:qid).to_i
    # On doit s'assurer d'abord que ça n'est pas un questionnaire
    # normal avec l'auteur qui triche
    q = Unan::Quiz::get(qid)
    if q.multi?
      # => OK
      # Il faut remettre le travail de ce quiz dans la
      # liste des quiz courant de l'auteur

      # Le travail propre à l'auteur et au questionnaire
      quiz_work     = q.work
      # Son identifiant, qu'on va ajouter aux listes des
      # travaux courants
      quiz_work_id  = quiz_work.id
    else
      error "Vous ne pouvez pas recommencer ce questionnaire, voyons…"
    end
  else
    error "Vous ne pouvez pas exécuter cette opération…"
  end
end
