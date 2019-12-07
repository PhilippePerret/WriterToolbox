if(undefined == window.QuizQuestion){window.QuizQuestion = {}}

$.extend(window.QuizQuestion,{

  // Ré-initialisation des champs pour une nouvelle
  // réponse.
  init_new_question:function(){
    var champs_valeurs = [
      'input#question_id',
      "input#question_question",
      'textarea#question_raison',
      'textarea#question_indication',
      'textarea#reponses_json'
    ];
    var champs_vide_html = [
      'div#reponses'
    ];
    var champs_select = [
      'question_type_f',
      'question_type_c',
      'question_type_a'
    ];
    var champs_uncheck = [
      'question_masked',
      'question_type_o'
    ];
    UI.init_form({
      val:      champs_valeurs,
      select:   champs_select,
      uncheck:  champs_uncheck,
      empty:    champs_vide_html
    })
    $('input#question_nombre_reponses').val('0')
    QuizQuestion.last_id_reponse = 0 ;
    $("input#question_question").focus();
    window.scroll(0,0);
  },

  // Méthode appelée par le bouton "+ Réponse" dans le formulaire
  new_reponse:function(){
    // Il faut vider complètement le formulaire
    this.build_reponse_field();
    $('input#question_reponse_'+this.last_id_reponse+'_libelle').focus();
  },

  // Méthode principale appelée quand on clique sur le bouton
  // pour éditer une question.
  // +btn+ L'élement DOM du bouton, pour récupérer l'identifiant
  // de la question et le relname de la base du questionnaire (les
  // deux informations nécessaires pour trouver la question)
  edit: function(btn){
    btn = $(btn) ;
    var qid         = btn.attr('data-qid') ;
    var db_relname  = btn.attr('data-quiz') ;
    // On relève toutes les informations sur la question et
    // on les édite.
    Ajax.send({
      route:    'quiz/ajax',
      want:     'question',
      id:       qid,
      onreturn: $.proxy(QuizQuestion,'edit_poursuivre')
    })
  },
  edit_poursuivre: function(rajax){

    // Il faut vider complètement le formulaire
    this.init_new_question();

    // Il faut cacher le formulaire du quiz et
    // afficher le formulaire de la question
    window.scroll(0,0);
    $('form#edition_quiz').hide();
    $('form#edition_question_quiz').show();

    // Les données de la question, telles qu'elles sont enregistrées,
    // sans aucune modification
    var qdata = rajax.question ;

    // On règle le type
    var type = qdata.type ;
    qdata.type_f = type.substring(0,1);
    qdata.type_c = type.substring(1,2);
    qdata.type_a = type.substring(2,3);
    qdata.masked = type.substring(3,4) == '1';
    qdata.type_o = type.substring(4,5) == '1';

    // --- On met toutes les données --
    $(['id', 'question']).each(function(i, k){
      $('form#edition_question_quiz input#question_' + k).val( qdata[k])
    })
    // TEXTAREA
    $(['question', 'raison', 'indication']).each(function(i, k){
      $('form#edition_question_quiz textarea#question_' + k).val( qdata[k])
    })
    // MENU SELECT
    $(['type_f', 'type_c', 'type_a']).each(function(i, k){
      $('form#edition_question_quiz select#question_' + k).val( qdata[k])
    })
    // CASES À COCHER
    $(['type_o', 'masked']).each(function(i, k){
      $('form#edition_question_quiz input#question_' + k)[0].checked = qdata[k];
    })

    // $('form#edition_question_quiz input#question_question').
    // On construit le champ pour chaque réponse
    this.build_all_reponses_field(qdata.reponses);

  },

  // Méthode appelée par le lien-bouton pour revenir au formulaire
  // du quiz
  back_to_quiz: function(){
    window.scroll(0,0);
    $('form#edition_quiz').show();
    $('form#edition_question_quiz').hide();
  }
})
