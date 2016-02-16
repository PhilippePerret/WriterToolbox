if(undefined==window.Scenodico){window.Scenodico = {}}

$.extend(window.Scenodico, {

  set_operation:function(ope){
    this.form.find('input#operation').val(ope)
  },

  edit_mot_by_id:function(){
    this.set_operation('edit_mot_by_id');
    this.form.submit();
  },

  // Ré-initialise tout le formulaire
  reset_form:function(){
    var listes = {}
    listes.val = [
      'input#mot_id', 'input#mot_mot', 'input#mot_id_interdata',
      'textarea#mot_definition',
      'input#mot_categories',
      'input#mot_relatifs', 'input#mot_synonymes', 'input#mot_contraires',
      'textarea#mot_liens'
    ];
    listes.select = ['mot_type_def'];
    UI.init_form(listes);
  },

  // Méthode appelée quand on clique sur le bouton "Voir" ou "Show"
  // Elle prépare l'href du lien avant qu'il ne soit activé
  for_show:function(lien){
    mot_id = this.form.find('input#mot_id').val()
    $(lien).attr('href', "scenodico/"+mot_id+"/show");
    return true
  },

  on_choose_categorie:function(cate_id){
    var field_categories = this.form.find('input#mot_categories') ;
    var cates = field_categories.val().trim() ;
    if (cates == ""){ cates = [] }
    else { cates = cates.split(' ') }
    if ( (offset = cates.indexOf(cate_id)) < 0 ){
      // => Ajouter la catégorie
      cates.push(cate_id)
    } else {
      // => Retirer la catégorie
      cates.splice(offset, 1)
    }
    // Actualiser la valeur des catégories
    field_categories.val(cates.join(' '));
    // Remettre le menu à rien (au-dessus)
    $('select#categories')[0].selectedIndex = 0;
  }

})
Object.defineProperties(window.Scenodico, {

  'form':{
    get:function(){
      if(undefined== this._form){this._form = $('form#form_edit_mot')}
      return this._form;
    }
  }
})
