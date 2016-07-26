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
    (
      "<h2 class='titre'>#{titre}</h2>" +
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
    f << bouton_soumission_ou_autre.in_div(class: 'buttons')

    form_action = "quiz/#{id}/show"
    f = f.force_encoding('utf-8').in_form(id:"form_quiz", class:'quiz', action: form_action)
  end

  # Retourne le code HTML pour le bouton pour soumettre le
  # formulaire ou autre bouton si c'est un résultat
  def bouton_soumission_ou_autre
    if ureponses.nil?
      'Soumettre le quiz'.in_submit(class: 'btn')
    else
      'Essayer encore'.in_a(href: "quiz/#{id}/show?qdbr=#{suffix_base}", class: 'btn')
    end
  end

  # Code HTML pour la description du quiz, si elle existe
  def div_description
    if ureponses.nil?
      (
        (avant_description_quiz || '') +
        (description || '').deserb.formate_balises_propres.in_div(id: 'qdescription') +
        (apres_description_quiz || '')
      ).in_div(id: 'quiz_description')
    else
      ''
    end
  end

  def avant_description_quiz
    c = ''
    if data_generales.nil?
      if user.admin?
        # Rien pour le moment
      end
    else
      if data_generales[:note_max] < 20
        best_note = "#{data_generales[:note_max].to_f}/20"
        c << "Serez-vous capable de battre la meilleure note obtenue ? #{best_note.in_span(id: 'best_note')}".in_div
      end
    end
    return c.in_div(id: 'quiz_defi')
  rescue Exception => e
    debug e
    error e.message
    ''
  end

  def apres_description_quiz
    c = ''
    if user.admin?
      if data_generales.nil?
        c << 'Pas d’enregistrement encore effectué'.in_div
      end
    end
    if data_generales.nil?
      # c << 'Vous êtes le tout premier à remplir ce quiz !'.in_div
      c << ''
    else
      c << "Vous êtes le #{data_generales[:count] + 1}<sup>e</sup> visiteur à remplir ce quiz".in_div
      c << (
              "Note moyenne : <strong>#{data_generales[:moyenne].to_f}/20</strong> - " +
              "la plus faible : <strong>#{data_generales[:note_min].to_f}/20</strong>"
            ).in_div
      c << "Premier test : #{data_generales[:created_at].as_human_date(true, true)}<br />Dernier test : #{data_generales[:updated_at].as_human_date(true, true)}".in_div
    end
    return c.in_div(id: 'infos_generales')
  rescue Exception => e
    debug e
    return ''
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