# encoding: UTF-8
class ::Quiz

  # = main =
  #
  # Le résultat affiché, en fonction de la note, etc.
  #
  # Ce résultat est contenu dans la variable @report, qui est nulle
  # lors de l'affichage du formulaire
  def resultat
    return '' if @report.nil?
    if @error
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
    @message_note_finale.in_div(id: 'message_general', class: class_div_note_finale)
  end
  def div_nombre_points
    ("<span class='fright'>#{unombre_points} / #{nombre_points_total}</span>" + 'Nombre de points :').in_div
  end

  # Retourne la classe css en fonction de la note
  # obtenue
  def class_div_note_finale
    if unote_finale > 15
      @message_note_finale = "Bravo à vous, c'est un excellent résultat ! :-D"
      'good'
    elsif unote_finale > 10
      @message_note_finale = "C'est un résultat acceptable, mais reconnaissez-le, pas très brillant quand même. ;-)"
      'moyen'
    else
      @message_note_finale = "Puis-je être honnête ?… Ça n'est vraiment pas un bon résultat. :-( Pour vous améliorer, n'hésitez pas à consulter les ressources du site, à commencer par celles proposées dans les corrections ci-dessous. Courage !"
      'bad'
    end
  end

end
