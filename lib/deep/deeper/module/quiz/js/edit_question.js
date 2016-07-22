if(undefined == window.QuizQuestion){window.QuizQuestion = {}}

$.extend(window.QuizQuestion,{

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
      database_relname: db_relname,
      onreturn: $.proxy(QuizQuestion,'edit_poursuivre')
    })
  },
  edit_poursuivre: function(rajax){

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

    console.log('qdata.type_c = ' + qdata.type_c);

    // --- On met toutes les données --
    $(['id', 'question']).each(function(i, k){
      $('form#edition_question_quiz input#question_' + k).val( qdata[k])
    })
    $(['question', 'raison', 'indication']).each(function(i, k){
      $('form#edition_question_quiz textarea#question_' + k).val( qdata[k])
    })
    $(['type_f', 'type_c', 'type_a']).each(function(i, k){
      $('form#edition_question_quiz select#question_' + k).val( qdata[k])
    })

    // $('form#edition_question_quiz input#question_question').
    // On construit le champ pour chaque réponse
    this.build_all_reponses_field(qdata.reponses);


    console.dir(qdata);
  }
})
