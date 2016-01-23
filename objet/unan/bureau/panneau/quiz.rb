# encoding: UTF-8
class Unan
class Bureau

  # Enregistrement d'un questionnaire
  # L'opération est complexe
  def save_quiz
    flash "Je sauve les questionnaires"
  end

  # Retourne true si l'user a des questionnaires à remplir
  def has_quiz?
    quizes.count > 0
  end

  # Retourne un Array de Unan::Quiz (questionnaires à remplir)
  def quizes
    @quizes ||= begin
      user.get_var(:quiz_ids, []).collect do |wid|
        # ATTENTION : Les IDs de :quiz_ids sont des ids de
        # travaux, pas des ids de quiz. Il faut rechercher
        # l'id du quiz dans la propriété `item_id` du work
        # absolu.
        quiz_id = Unan::Program::Work::new(user.program,wid).abs_work.item_id
        iquiz = Unan::Quiz::new(quiz_id)
        # TODO Ici, on pourrait préciser certaines données volatiles
        # du questionnaire, par exemple pour savoir s'il est en
        # retard ou non. Il suffirait d'avoir des accessors de propriétés
        # et de les renseigner en fonction du travail.
        iquiz
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

require_module 'quiz'
class Quiz
  # {StringHTML} Retourne le code HTML intégral avec le formulaires
  # et les boutons pour soumettre chaque questionnaires
  def output_in_form
    form = String::new
    form << 'bureau_save_quiz'.in_hidden(name:'operation')
    form << output
    form << bureau.submit_button("Soumettre le questionnaire", {discret: false, tiny: false})
    code = form.in_form(id:"form_quiz_#{id}", class:'quiz', action: "bureau/home?in=unan&cong=quiz")
    # code += "".in_div(style:'clear:both;')
    # debug code
    code
  end
end #/Quiz
end #/Unan

# Pour lancer la sauvegarde des données du questionnaire
case param(:operation)
when 'bureau_save_quiz'
  bureau.save_quiz
end
