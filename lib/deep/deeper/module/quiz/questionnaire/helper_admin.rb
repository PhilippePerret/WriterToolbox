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
  # +dform+ {Hash} contenant les attributs du formulaire et
  # principalement :
  #   :action       l'action
  def form dform
    dform[:id]    ||= 'edition_quiz'
    dform[:class] ||= 'dim2080'
    tform.prefix= 'quiz'
    mess_id = "ID du quiz : #{id}".in_span(id: 'quizid', class: 'fright')
    (
      # Identifiant, qui doit être défini à l'instanciation
      # du quiz
      (id || '').in_hidden(name:'quiz[id]', id: 'quiz_id') +
      tform.field_text('Titre', 'titre', titre) +
      tform.field_select('Type', 'type', nil, {values: TYPES, text_before: mess_id}) +
      tform.field_checkbox('Ordre aléatoire pour les questions', 'random') +
      tform.field_text('', 'max_questions', nil, {class: 'short', placeholder: 'x', text_after: "questions au maximum (pour quiz à ordre aléatoire)"}) +
      tform.field_text('Questions', 'questions_ids', nil) +
      tform.field_description('Liste des IDs de questions, séparés par des espaces. Noter que s’il y a un nombre maximum de questions définies et que l’ordre est aléatoire, on peut ne pas préciser l’ordre. S’il est défini, on prendra les X questions dans cette liste.') +
      tform.field_textarea('Description', 'description', nil) +
      tform.field_description('Cette description est destinée à l’utilisateur. Elle sera placée en haut du questionnaire.') +
      tform.submit_button('Enregistrer')
    ).in_form(dform)
  end

end
