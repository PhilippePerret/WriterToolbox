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
    f << 'Soumettre le questionnaire'.in_submit(class: 'btn')

    html = ""
    html << "<h2 class='titre'>#{titre}</h2>"
    form_action = "quiz/#{id}/show?qbdr=#{suffix_base}"
    html << f.force_encoding('utf-8').in_form(id:"form_quiz", class:'quiz', action: form_action)
    html

  end

  def questions_formated
    '[Questions formatées]'
  end

  # Retourne la liste des questions à afficher en fonction des
  # choix :
  #   - Il peut y avoir un nombre limité de questions à afficher
  #   - Il peut y avoir un ordre aléatoire
  def questions_ids_2_display

    ids = ids.shuffle.shuffle if aleatoire?
  end

end
