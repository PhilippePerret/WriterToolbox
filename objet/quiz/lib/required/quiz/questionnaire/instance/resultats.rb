# encoding: UTF-8
class ::Quiz

  # Enregistre dans la table générale :cold, 'quiz' la soumission de
  # ce questionnaire et enregistre le résultat courant de l'user
  # s'il est identifié
  #
  # La méthode est appelée par Quiz#evaluate dans le module calcul.rb
  #
  # Noter qu'elle
  def save_resultat
    save_in_table_generale =
      if user.identified?
        save_resultat_user
      else
        app.session['last_quiz'] != "#{id}-#{suffix_base}"
      end
    save_soumission_in_table_generale if save_in_table_generale

    # Pour un visiteur non identifié, on mémorise ce quiz effectué
    # pour qu'il ne puisse pas l'enregistrer à nouveau au cours de
    # la même session.
    user.identified? || app.session['last_quiz'] = "#{id}-#{suffix_base}"
  end

  # Enregistrement de la soumission courante dans la table
  # générale 'quiz' dans la base 'cold' du site
  def save_soumission_in_table_generale
    tbl_quiz = site.dbm_table(:cold, 'quiz')
    drequest = {
      where: "quiz_id = #{id} AND suffix_base = '#{suffix_base}'",
      colonne: [:moyenne, :note_min, :note_max, :count]
    }
    dupdate = tbl_quiz.select(drequest).first
    # Est-ce le tout premier enregistrement
    is_first_record = dupdate.nil?

    # Si c'est un premier enregistrement, il faut mettre toutes les
    # données dedans
    if is_first_record
      dupdate = {
          quiz_id: id, suffix_base: suffix_base,
          count: 0,
          note_min: 20.0, note_max: 0.0,
          moyenne: 0,
          created_at: NOW
      }
    end

    # Calcul de la nouvelle moyenne
    moy = (dupdate[:moyenne] * (dupdate[:count])) + unote_finale
    dupdate[:count] += 1
    dupdate[:moyenne] = (moy / dupdate[:count]).round(1)
    # Note minimum et maximum
    unote_finale < dupdate[:note_max] || dupdate[:note_max] = unote_finale
    unote_finale > dupdate[:note_min] || dupdate[:note_min] = unote_finale
    # Dernière date d'actualisation
    dupdate[:updated_at] = NOW

    if is_first_record
      tbl_quiz.insert( dupdate )
    else
      data_id = dupdate.delete(:id)
      tbl_quiz.update(data_id, dupdate)
    end
  end


  # Sauvegarde du résultat de l'user pour l'user s'il est identifié
  #
  # Si la méthode retourne TRUE, on enregistre aussi le résultat de
  # ce quiz dans la table générale (:cold, 'quiz'). Si FALSE, on ne
  # l'enregistre pas (ce qui arrive lorsqu'il n'y a pas assez de temps,
  # ou que c'est un enregistrement avec les mêmes points, etc.)
  #
  def save_resultat_user
    # On s'arrête ici si l'auteur n'est pas identifié. Sinon, on
    # enregistre son résultat, pour lui, dans la table des
    # résultats du questionnaire.
    # `true` pour dire qu'on peut poursuivre et enregistrer ce
    # questionnaire dans la table générale.
    return true unless user.identified?
    # Si le même questionnaire vient d'être enregistré, on ne l'enregistre pas
    # à nouveau
    last_five_minutes = NOW - (5*60)
    preres = table_resultats.get(where: "user_id = #{user.id} AND quiz_id = #{id} AND created_at > #{last_five_minutes}")
    preres == nil || begin
      error 'Vous ne pouvez pas réenregistrer ce questionnaire tout de suite…'
      return false
    end

    # On récupère tous les questionnaires identiques enregistrés
    preres = table_resultats.select(where: "user_id = #{user.id} AND quiz_id = #{id}")

    # Si l'user a fait le questionnaire trop de fois, on l'arrête ici
    max_records =
      case true
      when user.admin?      then 100
      when user.authorized? then 20
      else 2
      end
    preres.count < max_records || begin
      error "En qualité #{user.de_htype}, vous ne pouvez pas enregistrer ce questionnaire plus de #{max_records} fois."
      return false
    end

    # Résultat de l'user au format JSON
    ureponses_json = ureponses.to_json

    # On vérifie que les résultats des mêmes quiz soient différents
    preres.each do |hquiz|
      if hquiz[:reponses] == ureponses_json && hquiz[:points] == unombre_points
        error "Ce quiz a déjà été enregistré avec les mêmes réponses. Je ne l'enregistre pas à nouveau."
        return false
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
  else
    true # pour enregsitrer dans la table générale
  end
end #/Quiz
