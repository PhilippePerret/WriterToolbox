# encoding: UTF-8
class Unan
class Quiz


  # = main =
  #
  # Méthode principale appelée par la vue pour afficher le
  # questionnaire, soit en version formulaire, soit en version de
  # correction.
  #
  # {StringHTML} Retourne le code HTML intégral avec le formulaire
  # et les boutons pour soumettre chaque questionnaires
  # +options+
  #   forcer:       Si true, on force la reconstruction du questionnaire
  #   simulation:   Si true, c'est une simulation
  def output_in_container options = nil
    options ||= Hash::new

    # Note : options[:correction] est utilisé pour les simulations
    @for_correction = true if options[:correction] == true

    if correction?
      # Correction du questionnaire
      code_corrections_et_commentaires
    else
      # Affichage du questionnaire pour remplissage
      form = String::new
      form << 'bureau_save_quiz'.in_hidden(name:'operation')
      form << id.in_hidden(name:'quiz[id]', id:"quiz_id-#{id}")
      form << output(forcer = !!options[:forcer])
      form_action = options[:simulation] ? "quiz/#{id}/simulation?in=unan_admin" : "bureau/home?in=unan&cong=quiz"
      form << bureau.submit_button("Soumettre le questionnaire", {discret: false, tiny: false})

      html = ""
      html << titre.in_div(class:'titre') unless no_titre?
      html << form.in_form(id:"form_quiz_#{id}", class:'quiz', action: form_action)
      html
    end
  end

  # Méthode appelée par la vue quiz/show.erb, c'est-à-dire lorsque
  # l'user veut revoir un de ses quiz.
  def output_archives
    @for_correction = true
    code_corrections_et_commentaires
  end

  # {StringHtml} Retourne le code HTML pour afficher
  # le questionnaire.
  # Ce code est enregistré dans la propriété :output
  # dans la base de données, pour accélérer.
  # Si +forcer+ est true, on force la construction du questionnaire
  # même si la donnée output est définie dans la base. C'est utilisé
  # par l'édition pour actualiser chaque fois.
  # Noter que puisque la méthode get_all est appelée en mode édition,
  # ce output est défini. C'est pourquoi il faut mettre le forcer et
  # le out_of_date? avant de tester @output contre nil.
  def output forcer = false
    unless_not_exists
    @output = nil if forcer || out_of_date?
    @output ||= begin
      (forcer || get(:output).empty?) ? build : get(:output) +
      code_for_regle_reponses
    end
  end

end #/Quiz
end #/Unan
