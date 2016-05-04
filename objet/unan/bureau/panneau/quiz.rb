# encoding: UTF-8
Unan::require_module 'quiz'
class Unan
class Bureau

  # Enregistrement d'un questionnaire
  # L'opération est complexe
  def save_quiz
    quiz_id = param(:quiz)[:id].to_i_inn
    raise "Aucun questionnaire n'a été soumis…" if quiz_id == nil
    Unan::Quiz::get(quiz_id).evaluate_and_save
  end

  # {Array of User::UQuiz} Liste des derniers questionnaires remplis,
  # pour information sur le bureau (panneau des quiz)
  # ATTENTION : Il s'agit d'instances User::UQuiz et
  # PAS des instances Unan::Quiz
  #
  def last_quiz
    @last_quiz ||= user.quizes(created_after: NOW - 4.days)
  end

  # Retourne true si l'user a des questionnaires à remplir
  def has_quiz?
    quizes.count > 0
  end

  # Retourne un Array de Unan::Quiz (questionnaires à remplir)
  def quizes
    @quizes ||= begin
      current_pday.undone_quiz.collect do |hdata|
        debug "hdata: #{hdata.inspect}"
        Unan::Quiz::get(hdata[:item_id])
      end
    end
  end

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
  bureau.save_quiz
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
