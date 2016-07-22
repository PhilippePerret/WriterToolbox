# encoding: UTF-8
=begin

Méthodes pour construire le quiz

=end
class Quiz

  # Méthode principale pour la construction du
  # quiz
  def build
    options = Hash.new # pour le moment (voir si nécessaire)
    # Affichage du questionnaire pour remplissage
    f = ''
    f << 'evaluate_quiz'.in_hidden(name:'operation')
    f << id.in_hidden(name:'quiz[id]', id:"quiz_id-#{id}")
    f << questions_formated
    f << 'Soumettre le questionnaire'.in_submit(class: 'btn').in_div(class: 'buttons')

    form_action = "quiz/#{id}/show?qbdr=#{suffix_base}"
    f = f.force_encoding('utf-8').in_form(id:"form_quiz", class:'quiz', action: form_action)

    # Le code complet retourné
    "<h2 class='titre'>#{titre}</h2>" +
    f.in_div(class: 'quiz')
  end

  # Retourne la liste des questions mises en bon format
  def questions_formated
    questions_ids_2_display.collect{ |qid| Question.new(self, qid).output }.join('')
  end

end
