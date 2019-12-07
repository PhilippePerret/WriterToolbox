# encoding: UTF-8
=begin

  Module contenant les méthodes d'helper pour l'administration
  du quiz, à commencer par le formulaire d'édition du quiz

=end
site.require 'form_tools'
alias :tform :form

class Quiz

  # {StrintHTML} Retourne le code HTML pour le formulaire d'édition du
  # quiz.
  #
  # C'est aussi cette méthode qui teste pour voir s'il faut enregistrer
  # le formulaire (en fonction du param :operation).
  #
  # +dform+ {Hash} contenant les attributs du formulaire et
  # principalement :
  #   :action       l'action
  def form
    # Actions à accomplir, par exemple la sauvegarde
    # du questionnaire ou d'une question
    case param(:operation)
    when 'save_data_quiz'
      # Enregistrement des données du questionnaire
      save_data
    when 'save_data_question_quiz'
      # Enregistrement des données de la question éditée
      Question.save_data_question(self)
    end

    # Attributs pour le formulaire
    dform = {
      action: "quiz/#{id}/edit",
      id:     'edition_quiz',
      class:  'dim2080'
    }

    # Il faut ajouter les javascripts du dossier js et les css
    # du dossier css
    page.add_javascript Dir["#{Quiz.folder_lib}/js/**/*.js"]
    page.add_css Dir["#{Quiz.folder_lib}/css/**/*.css"]

    tform.prefix= 'quiz'

    # debug "ID quiz : #{id.inspect}"
    # debug "DATA QUIZ : #{get_all.pretty_inspect}"

    # Liste des groupes
    # TODO: Plus tard, les récupérer dans la table elle-même (table des
    # quiz)
    liste_groupes = [
      ['', 'Choisir parmi…'],
      ['scenodico',   'Scénodico'],
      ['filmodico',   'Filmodico'],
      ['autre',       'Autre']
    ]
    onclick = "$('input#quiz_groupe').val(this.value)"
    menu_groupes = liste_groupes.in_select(onchange: onclick)
    bouton_new_question = 'Nouvelle question'.in_a(onclick: 'QuizQuestion.new_question()')

    mess_id = "ID du quiz : #{id}".in_span(id: 'quizid', class: 'fright')

    # Les Ids de questions (après l'enregistrement, elles sont transformées
    # en String)
    case questions_ids
    when Array
      # OK
    when String then
      @questions_ids = questions_ids.split(' ')
      debug "@questions_ids : #{@questions_ids.inspect}"
    else
      raise('Les questions_ids ont un format invalide ' + "(#{questions_ids.class})")
    end

    # La case à cocher pour mettre en quiz courant, ou le texte
    # indiquant qu'il est en quiz courant
    cb_quiz_courant =
      if current?
        messcurrent = 'Ce quiz est le quiz courant. La seule façon de le changer est de mettre un autre quiz en quiz courant (car il faut qu’il y ait toujours un quiz courant).'.in_p(class: 'tiny')
        hiddencurrent = 'on'.in_hidden(name:'quiz[quiz_courant]')
        tform.field_raw('', '', nil, {field: messcurrent + hiddencurrent})
      else
        tform.field_checkbox('Mettre en quiz courant', 'quiz_courant') +
        tform.field_description('Si cette case est cochée, le quiz sera mis en quiz courant et remplacera le quiz courant s’il existe.')
      end

    (
      # Identifiant, qui doit être défini à l'instanciation
      # du quiz
      (id || '').in_hidden(name:'quiz[id]', id: 'quiz_id') +
      'save_data_quiz'.in_hidden(name: 'operation') +
      line_identifiant_et_bouton +
      tform.field_text('Titre', 'titre', titre) +
      tform.field_text('Groupe', 'groupe', groupe, {class: 'medium', text_after: menu_groupes}) +
      tform.field_description("Une base pouvant contenir des questionnaires de type varié (par exemple sur le scénodico ET sur le filmodico) on peut préciser par ce groupe les groupes possibles.") +
      tform.field_select('Type', 'type', nil, {values: TYPES, text_before: mess_id}) +
      cb_quiz_courant +
      tform.field_checkbox('Ordre aléatoire pour les questions', 'random', random?) +
      tform.field_checkbox('Ne pas lister (test ou quiz en cours de fabrication)', 'hors_liste', hors_liste?) +
      tform.field_checkbox('Quiz ré-utilisable', 'reusable', reusable?) +
      tform.field_description('Pour le moment, seulement utile pour les quiz du programme UNAN, pour des quiz qu’on peut refaire autant qu’on veut.') +
      tform.field_text('', 'max_questions', nombre_max_questions, {class: 'short', placeholder: 'x', text_after: "questions au maximum (pour quiz à ordre aléatoire)"}) +
      tform.field_text("Questions (#{questions_ids.count})", 'questions_ids', questions_ids.join(' ')) +
      tform.field_raw('', '', nil, {field: "#{bouton_new_question}"}) +
      tform.field_description('Liste des IDs de questions, séparés par des espaces. Noter que s’il y a un nombre maximum de questions définies et que l’ordre est aléatoire, on peut ne pas préciser l’ordre. S’il est défini, on prendra les X questions dans cette liste.') +
      ul_questions +
      tform.field_textarea('Description', 'description', description) +
      tform.field_description('Cette description est destinée à l’utilisateur. Elle sera placée en haut du questionnaire.') +
      tform.submit_button('Enregistrer')
    ).in_form(dform) +
    Quiz::Question.formulaire_edition_question(self, dform)

  end
  # /form

  # Code HTML de la ligne de formulaire contenant l'identifiant
  # du formulaire et les boutons d'édition
  def line_identifiant_et_bouton
    # Bouton pour afficher le questionnaire
    btn_show = 'Aperçu'.in_a(class: 'btn small', href: "quiz/#{id}/show", target: :new)
    # Bouton pour revenir à la liste des questionnaires
    btn_list = 'Liste des quiz'.in_a(class: 'btn small', href: 'quiz/list')
    btn_init = 'Init new'.in_a(onclick: "QuizQuestion.init_new()")
    tform.field_raw('', '', nil, {field: "#{btn_show}#{btn_list}".in_div(class: 'btns')})
  end

  # Retourne le div qui contient les questions du questionnaire, avec des
  # boutons pour les retirer ou les éditer
  def ul_questions
    questions_ids.count > 0 || ( return '' )
    dquestions = table_questions.select(where: "id IN (#{questions_ids.join(', ')})")

    ul = dquestions.collect do |dquestion|
      qid = dquestion[:id]
      (
        (
          'edit'.in_a(class: 'tiny', onclick: "QuizQuestion.edit(this)", 'data-qid' => qid) +
          'sup'.in_a(class: 'tiny', onclick: "$('li#li-q-#{qid}').remove();QuizQuestion.reordonne_questions()")
        ).in_div(class: 'btns fright tiny') +
        dquestion[:question].in_span
      ).in_li(id: "li-q-#{qid}", 'data-qid' => qid)

    end.join('').in_ul(id: 'ul_questions')

    (
      'Questions, qui peuvent être agencées ou supprimées simplement en utilisant le bouton “sup” pour les supprimer ou en les déplaçant à la souris. Il faut ensuite <strong>penser à enregistrer</strong>.'.in_div(class:'tiny') +
      ul
    ).in_fieldset(id: 'fs_questions', legend: 'Liste des questions')
  end

end
