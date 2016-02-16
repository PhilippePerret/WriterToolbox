if(undefined==window.Filmodico){window.Filmodico = {}}
$.extend(window.Filmodico, {

  on_click_submit: function(){
    this.form.find('input#operation').val('save_film');
    return true
  },

  // Méthode appelée quand on blur d'un champ "people", pour
  // mettre en forme. Pour l'instant, on ne fait rien.
  on_blur_people_field:function(field){
    var val = field.val();
  },

  // Méthode appelée quand on choisit un pays dans la liste
  // des pays
  on_choose_pays:function(pays){
    var field_pays = $('input#film_pays') ;
    var val = field_pays.val();
    if(val == ""){val = []}
    else{val = val.split(' ')}
    if( (offset = val.indexOf(pays)) < 0){
      // => Ajouter ce pays
      val.push(pays)
    } else {
      // => Enlever ce pays
      val.splice(offset, 1)
    }
    val = val.join(' ');
    field_pays.val(val);
  },

  // Méthode appelée quand on clique sur le bouton "Charger" à
  // côté de ID. On charge le film par son ID
  load_by_id:function(){
    this.form.find('input#operation').val("edit_film_by_id");
    this.form.submit();
  },

  load_by_film_id:function(){
    this.form.find('input#operation').val("edit_film_by_film_id");
    this.form.submit();
  },
  load_by_sym_id:function(){
    this.form.find('input#operation').val("edit_film_by_sym_id");
    this.form.submit();
  },


  // Ré-initialise le formulaire (pour un nouveau film)
  reset_form:function(){
    listes = {}
    listes.val = [
      'input#film_id', 'input#film_film_id', 'input#film_sym',
      'input#film_titre', 'input#film_titre_fr', 'textarea#film_resume',
      'input#film_duree', 'input#film_pays', 'input#film_duree_generique', 'input#film_annee',
      'textarea#film_realisateur', 'textarea#film_auteurs',
      'textarea#film_producteurs', 'textarea#film_acteurs', 'textarea#film_musique'
    ]
    UI.init_form(listes);
    // On masque aussi les champs pour les 3 identifiants pour ne pas
    // être tenté d'y inscrire les valeurs
    $(['id', 'film_id', 'sym']).each(function(i,o){
      $('input#film_'+o).css('visibility', 'hidden')
    })
  }

});
Object.defineProperties(window.Filmodico,{

  'form':{
    get:function(){
      if(undefined == this._form){this._form = $('form#form_edit_film')}
      return this._form
    }
  }
})


$('document').ready(function(){

  // On rend tous les champs de texte people sensible au blur
  // pour pouvoir corriger le texte
  $('textarea.people').bind('blur', function(){$.proxy(Filmodico, 'on_blur_people_field', $(this))()})

})
