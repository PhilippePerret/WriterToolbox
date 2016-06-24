# encoding: UTF-8
class Unan
class Quiz

  # Enregistrement du quiz, après son évaluation et avant
  # son réaffichage.
  #
  # Note : Ici, on ne connait pas encore le travail auteur
  # associé à ce questionnaire, donc il faut le retrouver
  def save_this_quiz
    auteur.table_quiz.insert(data2save.merge(work_id: work.id))
  end

  # Les données du questionnaire à enregistrer dans la
  # table de l'auteur, de ses réponses au questionnaire
  # courant
  #
  # Pour le moment, si c'est un questionnaire de type
  # "multi" (ré-utilisable), on n'enregistre pas les
  # réponses.
  def data2save
    @data2save ||= {
      # L'identifiant absolu du quiz
      # Noter qu'il ne peut pas être identique à l'id
      # du questionnaire lui-même. Mais ici, +id+ correspond
      # à l'identifiant absolu du quiz absolu, pas à celui
      # de l'auteur.
      quiz_id:    id,
      work_id:    awork_id,
      type:       type,
      reponses:   (multi? ? nil : auteur_reponses.to_json),
      points:     auteur_points,
      max_points: max_points,
      created_at: NOW
    }
  end

  # Marquer le travail qui a conduit à ce questionnaire comme
  # exécuté. Noter qu'on le fait même quand c'est par exemple
  # une validation des acquis et qu'elle n'est pas réussie. Cela
  # reposera simplement le questionnaire plus tard, mais un questionnaire
  # est toujours enregistré comme record.
  #
  # Noter qu'on ne compte les points, dans le cas où c'est un
  # questionnaire ré-utilisable, que la première fois
  def mark_work_done
    return error( "Impossible de trouver le travail de ce questionnaire…" ) if work.nil?
    doit_ajouter_points = !(multi? && quiz_existe_deja?)
    work.set_complete( doit_ajouter_points )
  end


  # Méthode qui reprogramme le questionnaire pour plus tard lorsqu'il
  # n'a pas été rempli correctement (pour le type :validation_acquis)
  #
  # OBSOLÈTE : Pour le moment, on ne peut plus reprogrammer un
  # travail.
  def reprogrammer_questionnaire nombre_jours = 7
    return
    hnew_work = {
      program_id:   work.program.id,
      abs_work_id:  work.abs_work_id,
      status:       0,
      options:      "",
      points:       0,
      ended_at:     nil,
      created_at:   NOW + nombre_jours.days,
      updated_at:   NOW + nombre_jours.days
    }
    new_work = Unan::Program::Work::new(work.program, nil)
    new_work.instance_variable_set('@data2save', hnew_work)
    new_work_id = new_work.create
  end

end #/Quiz
end #/Unan
