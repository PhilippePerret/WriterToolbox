# encoding: UTF-8
class ::Quiz

  # Enregistre le résultat courant de l'user identifié
  def save_resultat
    # Mesure de protection
    user.identified? || raise('Seul un user inscrit peut enregistrer un résultat.')
    # Si le même questionnaire vient d'être enregistré, on ne l'enregistre pas
    # à nouveau
    last_five_minutes = NOW - (5*60)
    preres = table_resultats.get(where: "user_id = #{user.id} AND quiz_id = #{id} AND created_at > #{last_five_minutes}")
    preres == nil || (raise 'Vous ne pouvez pas réenregistrer ce questionnaire tout de suite…')

    # On récupère tous les questionnaires identiques enregistrés
    preres = table_resultats.select(where: "user_id = #{user.id} AND quiz_id = #{id}")

    # Si l'user a fait le questionnaire trop de fois, on l'arrête ici
    max_records =
      case true
      when user.admin?      then 100
      when user.authorized? then 20
      else 2
      end
    preres.count < max_records || (raise "En qualité #{user.de_htype}, vous ne pouvez pas enregistrer ce questionnaire plus de #{max_records} fois.")

    # Résultat de l'user au format JSON
    ureponses_json = ureponses.to_json

    # On vérifie que les résultats des mêmes quiz soient différents
    preres.each do |hquiz|
      if hquiz[:reponses] == ureponses_json && hquiz[:points] == unombre_points
        raise "Ce quiz a déjà été enregistré avec les mêmes réponses. Je ne l'enregistre pas à nouveau."
      end
    end

    # --- On peut enregistrer ce quiz ---
    data_quiz = {
      user_id:      user.id,
      quiz_id:      self.id,
      reponses:     ureponses_json,
      note:         unote_finale,
      points:       unombre_points,
      created_at:   NOW
    }
    table_resultats.insert(data_quiz)
  rescue Exception => e
    debug e
    error e.message
  end
end #/Quiz
