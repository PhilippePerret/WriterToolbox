# encoding: UTF-8
=begin

  Module contenant les méthodes d'helper pour l'administration
  du quiz, à commencer par le formulaire d'édition du quiz

=end
site.require 'form_tools'
alias :tform :form

class ::Quiz

  # {StrintHTML} Retourne le code HTML pour le formulaire d'édition du
  # quiz.
  #
  # C'est aussi cette méthode qui teste pour voir s'il faut enregistrer
  # le formulaire.
  #
  # +dform+ {Hash} contenant les attributs du formulaire et
  # principalement :
  #   :action       l'action
  def form dform

    case param(:operation)
    when 'save_data_quiz'
      # Enregistrement des données du questionnaire
      save_data
    when 'save_data_question_quiz'
      # Enregistrement des données de la question éditée
      Question.save_data_question(self)
    end

    # Il faut ajouter les javascripts du dossier js
    page.add_javascript Dir["#{site.folder_module}/quiz/js/*.js"]

    dform[:id]    ||= 'edition_quiz'
    dform[:class] ||= 'dim2080'
    tform.prefix= 'quiz'

    # Liste des groupes
    # TODO: Plus tard, les récupérer dans la table elle-même (table des
    # quiz)
    liste_groupes = [['', 'Choisir parmi…'],['scenodico', 'Scénodico'], ['filmodico', "Filmodico"]]
    onclick = "$('input#quiz_groupe').val(this.value)"
    menu_groupes = liste_groupes.in_select(onchange: onclick)
    bouton_new_question = 'Nouvelle question'.in_a(onclick: "$('form#edition_question_quiz').show();$('form#edition_quiz').hide()")

    mess_id = "ID du quiz : #{id}".in_span(id: 'quizid', class: 'fright')
    (
      # Identifiant, qui doit être défini à l'instanciation
      # du quiz
      (id || '').in_hidden(name:'quiz[id]', id: 'quiz_id') +
      'save_data_quiz'.in_hidden(name: 'operation') +
      tform.field_text('Titre', 'titre', titre) +
      tform.field_text('Groupe', 'groupe', groupe, {class: 'medium', text_after: menu_groupes}) +
      tform.field_description("Une base pouvant contenir des questionnaires de type varié (par exemple sur le scénodico ET sur le filmodico) on peut préciser par ce groupe les groupes possibles.") +
      tform.field_select('Type', 'type', nil, {values: TYPES, text_before: mess_id}) +
      tform.field_checkbox('Ordre aléatoire pour les questions', 'random') +
      tform.field_text('', 'max_questions', nil, {class: 'short', placeholder: 'x', text_after: "questions au maximum (pour quiz à ordre aléatoire)"}) +
      tform.field_text('Questions', 'questions_ids', nil) +
      tform.field_raw('', '', nil, {field: "#{bouton_new_question}"}) +
      tform.field_description('Liste des IDs de questions, séparés par des espaces. Noter que s’il y a un nombre maximum de questions définies et que l’ordre est aléatoire, on peut ne pas préciser l’ordre. S’il est défini, on prendra les X questions dans cette liste.') +
      tform.field_textarea('Description', 'description', nil) +
      tform.field_description('Cette description est destinée à l’utilisateur. Elle sera placée en haut du questionnaire.') +
      tform.submit_button('Enregistrer')
    ).in_form(dform) +
    Quiz::Question.formulaire_edition_question(self, dform)
  end

end
