# encoding: UTF-8

site.require 'form_tools'
alias :tform :form

class ::Quiz
  class Question
    class << self

      # Formulaire d'édition d'une question
      #
      # Rappel : pour des questions de facilité, ce formulaire
      # est placé sous le formulaire d'édition du quiz
      def formulaire_edition_question quiz, dform, question = nil
        question ||= new(quiz, nil)
        dform[:id] = 'edition_question_quiz'
        dform.merge!(style:'display:none')
        tform.prefix= 'question'
        form.objet  = param(:question) || Hash.new # pour le moment
        bouton_generate_yaml_file = "Entrer les données à partir d'un fichier YAML".in_a(href:'question/from_yaml?in=unan_admin/quiz')
        lien_init_question    = "Init new".in_a(class:'btn small', onclick:"$.proxy(QuizQuestion, 'init_new')()")
        lien_edit_question    = "Edit".in_a(onclick:"$('input#operation').val('edit_question');$('form#form_question_edit').submit();", class:'small btn')
        lien_destroy_question = "Détruire".in_a(onclick:"$.proxy(QuizQuestion,'on_want_destroy')()", class:'small btn warning')

        (
          # On ne met pas tout de suite l'opération pour éviter les erreurs
          ''.in_hidden(name:'operation', id:'operation') +
          tform.field_text("ID", 'id', nil, {class:'short id_field', text_after: "#{lien_edit_question} #{lien_destroy_question} #{lien_init_question}"}) +
          tform.field_description("Mettre ID à rien pour générer une nouvelle question.") +
          tform.field_text('Question', 'question', nil, {class:'bold'}) +
          champs_reponses +
          # TYPE (checkbox ou radio)
          tform.field_select("Type",      'type_f', question.type_f, {values: ::Quiz::Question::TYPES}) +
          tform.field_select("Choix",     'type_c', question.type_c, {values: [['r', "Un seul choix (radio)"], ['c', "Plusieurs choix (checkboxes)"]]}) +
          tform.field_select("Affichage", 'type_a', question.type_a, {values: [['v', "L'un en dessous de l'autre"], ['h', "En ligne"], ['m', "En menu"]]}) +
          # INDICATION
          tform.field_textarea("Indication", 'indication', nil) +
          tform.field_description("Cette indication sera écrite en petit sous la question et permettra à l'auteur de mieux comprendre cette question. Notez qu'il y a déjà une indication automatique lorsque ce sont des checkboxes au lieu des boutons-radio.") +
          # RAISON
          tform.field_textarea("Raison bonne réponse", 'raison', nil) +
          tform.field_description("Dans le cas d'un vrai test, on peut donner ici la raison de la bonne réponse et aussi pourquoi les autres réponses ne sont pas valables.") +
          # Le bouton submit, qui met également la valeur 'operation' (elle n'est pas
          # mise par défaut pour éviter d'enregistrer une question avec la touche entrée)
          tform.submit_button("Enregistrer la question", {onclick:"$('form#edition_question_quiz input#operation').val('save_data_question_quiz')"})

        ).in_form(dform)
      end

      def champs_reponses
        <<-HTML
<div id="reponses"></div>
  #{tform.field_description('Ajouter les réponses en précisant leur nombre de points. S\'il y a <strong>une seule bonne réponse</strong>, il faut mettre 0 points aux autres réponses et un nombre de points à la bonne réponse. S\'il y a <strong>plusieurs réponses possibles</strong>, on peut mettre différents points, et le plus grand nombre de points sera considéré comme la <strong>meilleure réponse</strong>.<br />Pour <strong>supprimer une réponse</strong>, vider son libellé.')}
<div class='row air'>
  <span class='libelle'></span>
  <span class='value'>
    #{' + réponse'.in_a(class:'btn small', onclick:"$.proxy(QuizQuestion,'new_reponse')()")}
  </span>
</div>
#{''.in_hidden(name:"question[nombre_reponses]", id:"question_nombre_reponses")}
<!-- Champ caché dans le cas où c'est une édition, pour mettre les réponses dans leur format brut (string) -->
<textarea id="reponses_json" style="display:none;">#{
  case tform.objet[:reponses]
  when String then tform.objet[:reponses]
  else tform.objet[:reponses].to_json
  end.force_encoding('utf-8')
  }
</textarea>
        HTML
      end
    end #/<<self
  end #/Question
end #/Quiz
