# encoding: UTF-8
Unan::require_module 'quiz'
class Unan
class Bureau

  # Enregistrement d'un questionnaire
  # L'opération est complexe
  def save_quiz
    quiz_id = param(:quiz)[:id].to_i_inn
    raise "Aucun questionnaire n'a été soumis…" if quiz_id == nil
    # debug "Questionnaire soumis : #{quiz_id}"
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
      user.get_var(:quiz_ids, []).collect do |wid|
        # ATTENTION : Les IDs de :quiz_ids sont des ids de
        # travaux, pas des ids de quiz. Il faut rechercher
        # l'id du quiz dans la propriété `item_id` du work
        # absolu.
        quiz_id = Unan::Program::Work::new(user.program,wid).abs_work.item_id
        iquiz = Unan::Quiz::get(quiz_id)
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

class Quiz
end #/Quiz

end #/Unan

# Pour lancer la sauvegarde des données du questionnaire
case param(:operation)
when 'bureau_save_quiz'
  bureau.save_quiz
end
