# encoding: UTF-8
=begin

Méthodes pour construire le quiz

=end
class Quiz

  # Réaffiche le questionnaire rempli par l'user courant
  #
  def reshow
    # Il faut indiquer que c'est un ré-affichage, pour ne pas chercher à
    # enregistrer le résultat.
    @is_reshown = true
    # On récupère les réponses précédentes données par l'user
    get_ureponses
    evaluate
    output
  end

  # Récupère les réponses de l'user à ce questionnaire.
  #
  # Deux façons de les récupérer :
  #   SOIT On se sert de l'identifiant du quiz et de l'identifiant
  #   de l'user et on récupère le dernier quiz soumis.
  #   SOIT Les paramètres définissent explicitement l'identifiant de
  #   la rangée de résultats (qui est connue quand c'est pour le programme
  #   UNAN) — Un test est néanmoins effectué pour être certain qu'il s'agit
  #   du même quiz et du même user pour éviter les attaques
  def get_ureponses
    if param(:qresid)
      hresultat = table_resultats.get(param(:qresid).to_i)
      hresultat[:quiz_id] == id || raise('Il ne s’agit pas du questionnaire voulu…')
      hresultat[:user_id] == user.id || raise('Vous êtes en train de vouloir pirater le questionnaire d’un autre…')
    else
      hresultat = table_resultats.select(where: "quiz_id = #{id} AND user_id = #{user.id}", order: 'created_at DESC', limit: 1, colonnes: [:reponses]).first
    end
    @ureponses = Hash.new
    JSON.load(hresultat[:reponses]).each do |k, v|
      @ureponses.merge!(k.to_i => v.to_sym)
    end
    # debug "@ureponses : #{@ureponses.inspect}"
  end

  # Méthode principale appelée pour afficher le
  # questionnaire
  def output
    page.add_javascript Dir["#{Quiz.folder_lib}/js/user/**/*.js"]
    page.add_css Dir["#{Quiz.folder_lib}/css/user/**/*.css"]
    build
  end

  # Méthode principale pour la construction du
  # quiz (tout le quiz, avec description, note finale, etc.)
  def build
    options = Hash.new # pour le moment (voir si nécessaire)

    # Affichage du questionnaire pour remplissage
    # Le code complet retourné
    (
      "<h2 class='titre'>#{titre}</h2>" +
      resultat          + # seulement après soumission
      div_introduction  + # description, etc.
      html_form
    ).in_div(class: 'quiz')
  end

  # Code HTML pour le formulaire du quiz
  def html_form
    f = String.new
    f << form_operation.in_hidden(name:'operation')
    f << id.in_hidden(name:'quiz[id]', id:"quiz_id-#{id}")
    # Le temps courant, au cas où, pour voir si le formulaire n'est
    # pas soumis trop vite
    f << NOW.in_hidden(name: 'quiz[time]')
    f << suffix_base.in_hidden(name: 'qdbr', id: 'qdbr')
    f << questions_formated
    f << bouton_soumission_ou_autre.in_div(class: 'buttons')

    f = f.force_encoding('utf-8').in_form(id: form_id, class:'quiz', action: form_action)
  end

  # ID du formulaire
  # Pour le redéfinir : quiz.form_id= <valeur>
  def form_id; @form_id ||= "form_quiz-#{id}" end
  def form_id= value; @form_id = value end

  # ACTION du formulaire
  # Pour le redéfinir : quiz.form_action= <valeur>
  def form_action; @form_action ||= "quiz/#{id}/show" end
  def form_action= value; @form_action = value end

  # OPÉRATION du formulaire
  # Pour la redéfinir : quiz.form_operation= <valeur>
  def form_operation; @form_operation ||= 'evaluate_quiz' end
  def form_operation= value; @form_operation = value end

  # Nom du bouton pour soumettre le quiz
  def form_submit_button; @form_submit_button ||= 'Soumettre le quiz' end
  def form_submit_button= value; @form_submit_button = value end

  # Le href pour un bouton recommencer d'un quiz ré-utilisable.
  # Dans la méthode appelante, doit être défini par :
  #   quiz.href_button_recommencer= "le/href/..."
  def href_button_recommencer; @href_button_recommencer ||= site.current_route.route end
  def href_button_recommencer= value; @href_button_recommencer = value end

  # Retourne le code HTML pour le bouton pour soumettre le
  # formulaire ou autre bouton si c'est un résultat
  def bouton_soumission_ou_autre
    if evaluation?
      if reusable?
        'Recommencer'.in_a(class: 'btn', href: href_button_recommencer)
      else
        ''
      end
    else
      form_submit_button.in_submit(class: 'btn')
    end
  end

  # Code HTML pour la description du quiz, si elle existe
  def div_introduction
    if ureponses.nil?
      (
        (avant_description_quiz || '') +
        description_formated +
        (apres_description_quiz || '')
      ).in_div(id: 'quiz_description')
    else
      ''
    end
  end

  def description_formated
    @description_formated ||= (description || '').deserb.formate_balises_propres.in_div(id: 'qdescription')
  end

  def avant_description_quiz
    pre_description? || return
    c = ''
    if data_generales.nil?
      if user.admin?
        # Rien pour le moment
      end
    else
      if data_generales[:note_max] < 20
        best_note = "#{data_generales[:note_max].to_f}/20"
        c << (
              "Serez-vous capable de battre la meilleure note obtenue ? #{best_note.in_span(id: 'best_note')}" +
              ' (et gagner un mois d’abonnement gratuit au site ;-))'.in_span(class: 'small')
              ).in_div
      end
    end
    return c.in_div(id: 'quiz_defi')
  rescue Exception => e
    debug e
    error e.message
    ''
  end

  def apres_description_quiz
    post_description? || return
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
      c << "Premier test : #{data_generales[:created_at].as_human_date(true, true, nil, 'à')}<br />Dernier test : #{data_generales[:updated_at].as_human_date(true, true, nil, 'à')}".in_div
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
