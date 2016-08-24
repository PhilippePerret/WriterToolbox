# encoding: UTF-8
class Quiz

  # = main =
  #
  # Le résultat affiché, en fonction de la note, etc.
  #
  # Ce résultat est contenu dans la variable @report, qui est nulle
  # lors de l'affichage du formulaire
  #
  def resultat
    return '' if @report.nil?
    if @error_evaluation
      @report.in_div(class: 'warning')
    else
      @report.in_div(class: "quiz_resultat")
    end
  end

  # Le rapport, à construire. Mais s'il y a une erreur, la variable
  # @report a déjà été renseignée avec l'erreur à afficher, dans un
  # cadre warning.
  def report
    @report ||= begin
      div_note_finale         +
      div_message_note_finale +
      div_nombre_points
    end
  end

  def div_note_finale
    ("<span id='note_finale'>#{unote_finale}/20</span>" + 'Note finale : ').in_div(id: 'div_note_finale', class: class_div_note_finale)
  end
  def div_message_note_finale
    # @message_note_finale != nil || class_div_note_finale
    message_note_finale.in_div(id: 'message_general', class: class_div_note_finale)
  end
  def div_nombre_points
    ("<span class='fright'>#{unombre_points} / #{nombre_points_total}</span>" + 'Nombre de points :').in_div
  end

  def message_note_finale
    message_note_finale? || (return '')
    @message_note_finale ||= begin
      debug "current_note_max : #{current_note_max.to_f}"
      debug "unote_finale = #{unote_finale.to_f}"
      if current_note_max && (unote_finale > 15 && unote_finale > current_note_max)
        # L'user a obtenu la note maximale pour ce quiz.
        # S'il est inscrit, il peut obtenir des jours d'abonnement gratuits,
        # mais seulement s'il n'en a pas déjà obtenu par le biais de ce
        # formulaire ou par le biais d'autres formulaire

        raison_jours = "QUIZ #{suffix_base} #{id}"

        # On doit déterminer si l'user peut bénéficier des jours gratuits
        can_have_jours = begin
          if user.identified?
            if user.autorisations_for_raison(raison_jours).count > 0
              flash('(Vous avez déjà obtenu des jours d’abonnement pour ce quiz)')
              false
            elsif user.autorisations_for_raison(/^QUIZ /).count > 5
              flash('Vous avez déjà obtenu des jours d’abonnement pour 5 quiz. C’est le maximum)')
              false
            elsif user.autorisation_a_vie?
              false
            else
              # Dans tous les autres cas, on peut obtenir les jours
              # gratuits
              true
            end
          else
            flash('Si vous aviez été inscrit(e), vous auriez pu obtenir 31 jours d’abonnement gratuits.')
            false
          end
        end
        data_image = {class: 'fleft'}
        if can_have_jours
          data_image.merge!(
            points: 31,
            raison: raison_jours
            )
        end
        ajout_message_jours =
          if can_have_jours
            ' (vous pouvez cliquer sur la mascotte ci-contre pour obtenir 31 jours d’abonnement gratuits !)'.in_span(class: 'small')
          else
            ''
          end
        image_mascotte(data_image) +
        "Bravo à vous ! Non seulement c'est un résultat excellent mais c'est également la meilleure note obtenue à ce test !#{ajout_message_jours}"
      elsif current_note_min && (unote_finale < 10 && unote_finale < current_note_min)
        "Non seulement ça n'est pas une très bonne note, mais c'est en plus la pire note obtenue à ce test !… :-( Vraiment navré pour vous."
      else
        if unote_finale == 20.0
          "Bravo à vous, c'est juste excellent ! :-D"
        elsif unote_finale > 15
          "Bravo à vous, c'est un excellent résultat ! :-D"
        elsif unote_finale > 10
          "C'est un résultat acceptable, mais reconnaissez-le, pas très brillant quand même. ;-)"
        else
          "On ne va pas se mentir, n'est-ce pas ? Ça n'est pas un bon résultat. :-( Pour vous améliorer, n'hésitez pas à consulter les ressources du site, à commencer par celles proposées dans les corrections ci-dessous. Courage !"
        end
      end
    end
  end

  # Retourne la classe css en fonction de la note
  # obtenue
  def class_div_note_finale
    if unote_finale > 15
      'good'
    elsif unote_finale > 10
      'moyen'
    else
      'bad'
    end
  end

end
