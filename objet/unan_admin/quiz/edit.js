if(undefined == window.Quiz){window.Quiz = {}}

$.extend(window.Quiz,{


  // Initialisation des champs pour un nouveau questionnaire
  init_new:function(){
    var champs_valeurs = [
      'input#quiz_id',
      'input#quiz_titre',
      'input#quiz_points',
      'input#quiz_questions_ids',
      'textarea#quiz_description'
    ];
    var champs_select = [
      'quiz_type'
    ]
    var champs_uncheck = [
      'quiz_option_no_titre',
      'quiz_option_description',
      'quiz_option_only_points_quiz'
    ]
    var champs_vide_html = [
      'div#overview'
    ]
    UI.init_form({
      val:      champs_valeurs,
      select:   champs_select,
      uncheck:  champs_uncheck,
      empty:    champs_vide_html
    })
  }

})
