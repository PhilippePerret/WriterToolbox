if(undefined==window.Cnarration){window.Cnarration = {}}

$.extend(window.Cnarration,{

  on_edit_by_id:function(lien){
    if (this.page_id == ""){
      F.error("Il faut indiquer l'ID de la page à éditer.");
      this.field_id.focus();
      return false
    }
    // this.field_operation.val("edit_page");
    // this.form.submit();
    $(lien).attr('href', "page/"+this.page_id+"/edit?in=cnarration");
    return true
  },

  on_submit_form:function(){
    this.field_operation.val("save_page");
    return true
  },

  on_show:function(lien){
    if (this.page_id == ""){
      F.error("Il faut indiquer l'ID de la page à montrer.");
      this.field_id.focus();
      return false
    }
    var href = "page/" + this.page_id + "/show?in=cnarration"
    $(lien).attr('href', href);
    return true
  },

  set_dossier_page:function(book_id){
    var dossier = $('select#epage_livre_id').find('option[value="'+book_id+'"]').attr("data-folder");
    $('span#dossier_page').html(dossier);
  },

  // Méthode appelée quand on change le type de la page pour en
  // faire par exemple un chapitre ou un texte-type
  on_change_type_page:function(type){
    var method ;
    if(type == "1" || type == "5"){
      // Les types avec une page réelle
      method = 'show'
    } else {
      // Les types chapitre
      method = 'hide'
    }
    $(['input#epage_handler', 'span#div-epage_create_file', 'select#epage_nivdev']).each(function(i, o){
      $(o)[method]();
    })
  },

  // Méthode appelée quand on clique sur le bouton "Tdm" à côté
  // du menu du livre, pour obtenir la table des matières du
  // livre dans une nouvelle fenêtre.
  got_to_book_tdm:function(lien){
    var href = "livre/"+this.livre_id+"/tdm?in=cnarration" ;
    $(lien).attr('href', href);
    return true
  },
  // Méthode appelée quand on clique sur le bouton "Edit Tdm" à
  // côté du menu du livre pour obtenir la table des matières
  // du livre en édition dans une nouvelle fenêtre.
  got_to_edit_book_tdm:function(lien){
    var href = "livre/"+this.livre_id+"/edit?in=cnarration" ;
    $(lien).attr('href', href);
    return true
  },

  reset_all:function(){
    var listes = {};
    listes.val = [
      'input#epage_id', 'input#epage_titre',
      'input#epage_handler',
      'textarea#epage_description'
    ];
    listes.select = [
      'epage_type', 'epage_nivdev', 'epage_livre_id'
    ];
    UI.init_form(listes);
    this.on_change_type_page("1")
  }

})
Object.defineProperties(window.Cnarration,{

  'form':{
    get:function(){
      if(undefined == this._form){this._form = $('form#form_edit_page')}
      return this._form;
    }
  },

  'field_operation':{
    get:function(){
      if(undefined == this._field_operation){this._field_operation = this.form.find('input#operation')}
      return this._field_operation
    }
  },
  'field_id':{
    get:function(){
      if(undefined == this._field_id){this._field_id = this.form.find('input#epage_id')}
      return this._field_id
    }
  },
  'page_id':{
    get:function(){ return this.field_id.val() }
  },
  'livre_id':{
    get:function(){return $('select#epage_livre_id').val()}
  }

})
