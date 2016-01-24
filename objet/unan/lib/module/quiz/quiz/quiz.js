if(undefined == window.Quiz){window.Quiz = {}}

$.extend(window.Quiz,{

  // Méthode qui remet les valeurs des choix
  // quand le questionnaire est rechargé
  regle_reponses:function( values ){
    var quiz_id = values.quiz_id ;
    var prefix_quiz  = "quiz-" + quiz_id ;
    var form_id   = 'form_quiz_'+quiz_id;
    var form_jid  = "form#" + form_id ;
    var o, id, jid, prefix, values ;
    for(var qid in values.reponses){
      o = values.reponses[qid];
      console.log("qid = " + qid);
      prefix = prefix_quiz + "_q_" + o.qid;
      console.log(o);
      switch(o.type){
        case 'error':
          // Une erreur sur une question, ou une question
          // non répondue
          $("div#question-"+o.qid).addClass('warning');
          break;
        case 'rad':
          // prefix + r_<id réponse>
          jid = 'input[type="radio"]#' + prefix + '_r_' + o.value ;
          $(jid)[0].checked = true;
          break;
        case 'sel':
          jid = "select#" + prefix ;
          $(jid).val("r_" + o.value) ;
          break;
        case 'sem':
          jid = "select#" + prefix ;
          values = new Array();
          $(o.value).each(function(ii,oo){values.push("r_" + oo)})
          console.log( "Values pour select multiple : " + values ) ;
          $(jid).val(values);
          break;
        case 'che':
          // Pour les checkboxes, c'est la propriété `value` qui
          // contient une liste des id des cases cochées, amputés
          // du prefix à ajouter pour construire le JID.
          $(o.value).each(function(ii,rid){
            jid = 'input[type="checkbox"]#' + prefix + "_r_" + rid ;
            console.log(jid) ;
            $(jid)[0].checked = true;
          })
          break;
        default:
          // $(o.jid).val(o.value)
          console.log("# IMPOSSIBLE DE TRAITER : " + o)
      }
    };
    // $(form_jid).find() etc.
  }
})
