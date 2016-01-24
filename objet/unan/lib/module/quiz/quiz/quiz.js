if(undefined == window.Quiz){window.Quiz = {}}

$.extend(window.Quiz,{

  // Méthode qui remet les valeurs des choix
  // quand le questionnaire est rechargé
  regle_reponses:function( values ){
    var quiz_id = values.quiz_id ;
    var prefix  = "quiz-" + quiz_id ;
    var form_id   = 'form_quiz_'+quiz_id;
    var form_jid  = "form#" + form_id ;
    var id ;
    $(values.reponses).each(function(i, o){
      switch(o.type){
        case 'error':
          // Une erreur sur une question, ou une question
          // non répondue
          $("div#question-"+o.qid).addClass('warning');
          break;
        case 'radio':
          $(o.jid)[0].checked = true;
          break;
        case 'checkbox':
          // Pour les checkboxes, c'est la propriété `value` qui
          // contient une liste des id des cases cochées, amputés
          // du prefix à ajouter pour construire le JID.
          $(o.value).each(function(ii,suf_id){
            jid = 'input[type="checkbox"]#' + prefix + "_" + suf_id ;
            $(jid)[0].checked = true;
          })
          break;
        default:
          $(o.jid).val(o.value)
      }
    })
    // $(form_jid).find() etc.
  }
})
