# encoding: utf-8

require 'json'

class OrgQuiz

  # Créer la données dans la base de donnée
  def create
    # Création des questions
    # Les questions doivent être créées avant le questionnaire pour
    # qu'on ait l'identifiant des questions
    create_questions
    
    # Création du questionnaire
    create_quiz
    flash "Questionnaire ##{id} enregistré avec succès."
  end


  # Enregistrement des données du quiz
  def create_quiz
    debug ""
    debug "Insertion dans la table du questionnaire : #{dataquiz2save}"
    #@id = table_quiz.insert(dataquiz2save)
  end
  # Enregistrement des questions
  def create_questions
    @qdata[:questions].each do |dquestion|
      dquestion.delete(:id)
      dquestion[:reponses] = dquestion[:reponses].to_json
      debug "Insertion dans la table des questions de #{dquestion.inspect}"
      # qid = table_questions.insert(dquestion)
      @qdata[:questions_ids] << qid
    end
  end

  # Données questionnaire à enregistrer
  def dataquiz2save
    {
      titre:         @qdata[:title],
      description:   @qdata[:description].nil_if_empty,
      questions_ids: @qdata[:questions_ids|,
      created_at:    NOW,
      updated_at:    NOW
    }
  end
end
