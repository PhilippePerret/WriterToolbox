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

    # Le code complet retourné
    "<h2 class='titre'>#{titre}</h2>" +
    (
      resultat        + # seulement après soumission
      div_description +
      html_form
    ).in_div(class: 'quiz')
  end

  # Code HTML pour le formulaire du quiz
  def html_form
    f = String.new
    f << 'evaluate_quiz'.in_hidden(name:'operation')
    f << id.in_hidden(name:'quiz[id]', id:"quiz_id-#{id}")
    # Le temps courant, au cas où, pour voir si le formulaire n'est
    # pas soumis trop vite
    f << NOW.in_hidden(name: 'quiz[time]')
    f << suffix_base.in_hidden(name: 'qdbr', id: 'qdbr')
    f << questions_formated
    f << 'Soumettre le quiz'.in_submit(class: 'btn').in_div(class: 'buttons')

    form_action = "quiz/#{id}/show"
    f = f.force_encoding('utf-8').in_form(id:"form_quiz", class:'quiz', action: form_action)
  end

  # Code HTML pour la description du quiz, si elle existe
  def div_description
    return '' if description.nil?
    description.in_div(class: 'quiz_description')
  end

  # Retourne la liste des questions mises en bon format
  def questions_formated
    questions_ids_2_display.collect{ |qid| Question.new(self, qid).output }.join('')
  end

  # Le préfixe name ajouté à toutes les réponses, pour le NAME
  # Ça donnera par exemple param(:q12r) pour obtenir toutes les
  # réponses du quiz #12 de la base courante.
  def prefix_reponse
    @prefix_reponse ||= "q#{id}r"
  end

end
