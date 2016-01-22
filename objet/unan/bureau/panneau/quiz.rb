# encoding: UTF-8
class Unan
class Bureau

  def save_quiz
    flash "Je sauve les questionnaires"
  end

  def has_quiz?
    true
  end

  def quizes
    [1,2].collect do |qid|
      Unan::Quiz::new(qid)
    end
  end

  def missing_data
    @missing_data ||= begin
      nil # pour le moment
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
    form << bureau.submit_button("Soumettre le questionnaire")
    form.in_form(id:"form_quiz_#{quiz_id}", action: "bureau/home?in=unan&cong=quiz")
  end
end #/Quiz
end #/Unan

# Pour lancer la sauvegarde des données du questionnaire
case param(:operation)
when 'bureau_save_quiz'
  bureau.save_quiz
end
