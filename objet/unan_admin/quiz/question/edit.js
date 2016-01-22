if(undefined == window.Question){window.Question = {}}

$.extend(window.Question,{
  last_id_reponse:0,

  // Tout ré-initialiser pour une nouvelle question
  reset_all: function(){
    $("input#question_question").val('');
    $('textarea#question_raison').val('');
    $('div#reponses').html("");
    $('input#question_nombre_reponses').val('0')
    $('textarea#reponses_json').val('');
    Question.last_id_reponse = 0 ;
  },

  // Méthode appelée par le bouton "+ Réponse" dans le formulaire
  new_reponse:function(){
    this.build_reponse_field();
    $('input#question_reponse_'+this.last_id_reponse+'_libelle').focus();
  },

  // Construction des réponses qui ont pu déjà être données
  build_all_reponses_field:function(reponses){
    reponses = JSON.parse(reponses) ;
    var libelle, points ;
    $(reponses).each(function(key, value){
      libelle = value.libelle ;
      points  = value.points  ;
      Question.build_reponse_field(key + 1, libelle, points) ;
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
    $('input#question_nombre_reponses').val(rep_id) ;
    var rep_code  = "<div class='question'>" +
    "<input type='hidden' name='question[reponse_"+rep_id+"][id]' id='question_reponse_"+rep_id+"_id' value='"+rep_id+"' />" +
    "<input type='text' style='width:500px' name='question[reponse_"+rep_id+"][libelle]' id='question_reponse_"+rep_id+"_libelle' value=\""+rep_libelle+"\" />" +
    "<input type='text' class='short' name='question[reponse_"+rep_id+"][points]' id='question_reponse_"+rep_id+"_points' value='"+rep_points+"' /><span class='small'> pts </span>" +
    "</div>";
    rep_code = "<div class='row'><span class='libelle'>Réponse "+rep_id+"</span><span class='value'>"+rep_code+"</span></div>";
    $('div#reponses').append(rep_code) ;
  },

  // Méthode appelée quand on veut détruire la question
  on_want_destroy:function(){
    if( this.question_id == ""){
      return F.error("Il faut indiquer l'identifiant de la question à détruire.")
    }
    if(!confirm("Voulez-vous réellement détruire définitivement cette question ?")){return false}
    this.form.find("input#operation").val("destroy_question");
    this.form.submit();
  }
})
Object.defineProperties(window.Question,{
  'form':{
    get:function(){
      if(undefined == this._form){this._form = $('form#form_question_edit')};
      return this._form;
    }
  },
  'question_id':{
    get:function(){
      return $('input#question_id').val();
    }
  }
})



$(document).ready(function(){

  // Voir s'il y a déjà des réponses, par exemple lorsque
  // la question est éditée.
  var reponses_json = $('textarea#reponses_json').val();

  if (reponses_json != ""){
    // Construire tous les champs de réponses
    Question.build_all_reponses_field(reponses_json);
  } else {
    // Construire un premier champ réponse
    Question.build_reponse_field();
  }

  // Pour surveiller le changement de ID
  $('input#question_id').bind('change', function(){
    console.log("Il est vidé. Valeur du champ : ")
    console.log($(this).val()) ;
    if($(this).val() == ""){
      // Quand on vide le change de ID, c'est pour initialiser
      // une nouvelle question. il faut donc tout initialiser
      Question.reset_all();
    } else {
      // Plus tard, pour régler le bouton pour voir la question ?
    }
  })
})
