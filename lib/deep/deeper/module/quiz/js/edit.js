if(undefined == window.QuizQuestion){window.QuizQuestion = {}}

$.extend(window.QuizQuestion,{
  last_id_reponse:0,

  init_new:function(){
    var champs_valeurs = [
      'input#question_id',
      "input#question_question",
      'textarea#question_raison',
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
  },

  // Tout ré-initialiser pour une nouvelle question
  reset_all: function(){
  },

  // Méthode appelée par le bouton "+ Réponse" dans le formulaire
  new_reponse:function(){
    this.build_reponse_field();
    $('input#question_reponse_'+this.last_id_reponse+'_libelle').focus();
  },

  // Construction des réponses qui ont pu déjà être données
  build_all_reponses_field:function(reponses){
    if(!reponses) return ;
    reponses = JSON.parse(reponses) ;
    var libelle, points ;
    $(reponses).each(function(key, value){
      libelle = value.lib ;
      points  = value.pts  ;
      QuizQuestion.build_reponse_field(key + 1, libelle, points) ;
    })
  },

  //
  build_reponse_field:function(rep_id, rep_libelle, rep_points){
    if (undefined == rep_id ){
      rep_id = ++this.last_id_reponse
      rep_libelle = "" ;
      rep_points  = "" ;
    } else {
      this.last_id_reponse = parseInt(rep_id);
    }

    var id_libelle_field  = 'question_reponse_'+rep_id+'_libelle' ;
    var id_points_field   = 'question_reponse_'+rep_id+'_points';

    $('input#question_nombre_reponses').val(rep_id) ;
    var rep_code  = "<div class='question'>" +
    "<input type='hidden' name='question[reponse_"+rep_id+"][id]' id='question_reponse_"+rep_id+"_id' value='"+rep_id+"' />" +
    "<input type='text' style='width:500px' name='question[reponse_"+rep_id+"][libelle]' id='" + id_libelle_field + "' value=\""+rep_libelle+"\" />" +
    "<input type='text' class='short' name='question[reponse_"+rep_id+"][points]' id='" + id_points_field + "' value='"+rep_points+"' /><span class='small'> pts </span>" +
    "</div>";
    rep_code = "<div class='row'><span class='libelle'>Réponse "+rep_id+"</span><span class='value'>"+rep_code+"</span></div>";
    $('div#reponses').append(rep_code) ;

    // On met un capteur d'évènement pour gérer le retour chariot
    // dans ces nouveaux champs
    $('input#' + id_libelle_field).bind('focus', function(){
      $('input#' + id_libelle_field).bind('keypress', function(ev){return QuizQuestion.onkeypress_champ_reponse(ev, $(this))});
    });
    $('input#' + id_libelle_field).bind('blur', function(){
      $('input#' + id_libelle_field).unbind('keypress', function(ev){return QuizQuestion.onkeypress_champ_reponse(ev, $(this))});
    });
    $('input#' + id_points_field).bind('focus', function(){
      $('input#' + id_points_field).bind('keypress', function(ev){return QuizQuestion.onkeypress_champ_reponse(ev, $(this))});
    });
    $('input#' + id_points_field).bind('blur', function(){
      $('input#' + id_points_field).unbind('keypress', function(ev){return QuizQuestion.onkeypress_champ_reponse(ev, $(this))});
    });

  },

  // Méthode appelée quand on tape des lettres dans le champ
  // pour entrer la question. Si c'est un retour-chariot le traitement
  // suivant se produit :
  //  S'il existe un champ de réponse, on y va, sinon, on crée la
  // première réponse.
  onkeypress_champ_question:function(ev){
    if (ev.keyCode == 13){
      ev.preventDefault();
      ev.stopPropagation();

      if ($('input#question_reponse_1_libelle').length){
        $('input#question_reponse_1_libelle').focus();
      } else {
        this.new_reponse();
      }
      return false;
    }
    return true
  },
  onkeypress_champ_reponse: function( ev, champ){
    // ID du champ
    var fid = $(champ).attr('id') ;
    var dchamp = fid.split('_');
    var is_libelle = dchamp[3] == 'libelle' ;

    if (ev.keyCode == 13){
      ev.preventDefault();
      ev.stopPropagation();
      // Si on est dans le libelle, on passe dans le champ
      // de point, si on est dans le champ de points, on ajoute
      // une réponse en dessous
      if (is_libelle){
        dchamp[3] = 'points' ;
        var id_points = dchamp.join('_') ;
        $('input#'+id_points).focus();
      } else {
        this.new_reponse();
      }
      return false;
    }
    return true;
  },

  // Méthode appelée quand on veut détruire la question
  on_want_destroy:function(){
    if( this.question_id == ""){
      return F.error("Il faut indiquer l'identifiant de la question à détruire.")
    }
    if(!confirm("Voulez-vous réellement détruire définitivement cette question ?")){return false}
    this.form.find("input#operation").val("destroy_question");
    this.form.submit();
  },

  // Méthode appelée quand on réordonne l'ordre des questions
  // Il faut prendre le nouveau ordre et le mettre dans le champ
  reordonne_questions: function(){
    var field = $('form#edition_quiz input#quiz_questions_ids') ;
    var current_value = field.val();
    console.log("Valeur courante : " + current_value);
    // On récupère les valeurs dans la liste
    var new_value = [] ;
    $('ul#ul_questions > li').each(function(){
      new_value.push( $(this).attr('data-qid')) ;
    })
    new_value = new_value.join(' ') ;
    console.log("Nouvelle valeur : " + new_value) ;
    field.val(new_value) ;
  }
})
Object.defineProperties(window.QuizQuestion,{
  'form':{
    get:function(){
      if(undefined == this._form){this._form = $('form#edition_question_quiz')};
      return this._form;
    },
    configurable: true
  },
  'question_id':{
    get:function(){
      return $('input#question_id').val();
    },
    configurable: true
  }
})



$(document).ready(function(){

  // Voir s'il y a déjà des réponses, par exemple lorsque
  // la question est éditée.
  var reponses_json = $('textarea#reponses_json').val();

  if (reponses_json != ""){
    // Construire tous les champs de réponses
    QuizQuestion.build_all_reponses_field(reponses_json);
  } else {
    // Construire un premier champ réponse
    QuizQuestion.build_reponse_field();
  }

  $('input#question_question').bind('focus', function(){
    $('input#question_question').bind('keypress', function(ev){return QuizQuestion.onkeypress_champ_question(ev)})
  });
  $('input#question_question').bind('blur', function(){
    $('input#question_question').unbind('keypress', function(ev){return QuizQuestion.onkeypress_champ_question(ev)})
  })

  // On rend la liste des questions sortable pour pouvoir
  // définir l'ordre
  $('form#edition_quiz ul#ul_questions').sortable({
    axis: 'y',
    update: function(ev, ui){
      QuizQuestion.reordonne_questions()
    }
  })

  // On ferme le formulaire de la question
  // Note : on l'avait laissé ouvert pour que les select soient
  // bien réglés par le javascript, ce qui ne peut pas se faire
  // lorsque le formulaire est display: none
  $('form#edition_question_quiz').hide();
})
