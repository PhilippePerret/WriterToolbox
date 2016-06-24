# encoding: UTF-8
Unan::require_module 'quiz'
class Unan
class Bureau

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
  quiz.evaluate_and_save(awork_id: param(:quiz)[:awork_id])
  # Étudier et construire le retour en fonction du questionnaire
  quiz.commented_output
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

      # Ici, il faudrait faire quelque chose pour indiquer
      # qu'il ne faut pas afficher les résultats. Pour le
      # moment, je vais essayer en n'enregistrant pas les
      # résultats d'un tel test.

      cur_quizes  = user.get_var(:quiz_ids)
      cur_works   = user.get_var(:works_ids)

      # Suite à un bug, on retire ce qui n'est pas des nombres
      cur_quizes  = cur_quizes.select{|e| e.instance_of?(Fixnum)}
      cur_works   = cur_works.select{|e| e.instance_of?(Fixnum)}

      new_quizes = (cur_quizes << quiz_work_id).uniq
      new_works  = (cur_works << quiz_work_id ).uniq
      user.set_var(:quiz_ids,  new_quizes)
      user.set_var(:works_ids, new_works)

      # Pour forcer l'actualisation, au cas où, mais normalement,
      # la méthode bureau.quizes n'a pas encore été appelée, ici
      bureau.instance_variable_set('@quizes', nil)

    else
      error "Vous ne pouvez pas recommencer ce questionnaire, voyons…"
    end
  else
    error "Vous ne pouvez pas exécuter cette opération…"
  end
end
