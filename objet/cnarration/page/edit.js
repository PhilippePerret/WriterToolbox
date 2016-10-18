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

  on_edit_text:function(lien){
    if (this.page_id == ""){
      F.error("Il faut indiquer l'ID de la page dont le texte doit être édité.");
      this.field_id.focus();
      return false
    }
    var href = "page/" + this.page_id + "/edit_text?in=cnarration"
    $(lien).attr('href', href);
    return true
  },

  on_submit_form:function(){
    this.field_operation.val("save_page");
    return true
  },

  on_destroy:function(lien){
    if(false == confirm(this.confirmation_destruction_page)){return}
    if (this.page_id == ""){
      F.error("Il faut indiquer l'ID de la page à montrer.");
      this.field_id.focus();return false
    }
    var href = "page/" + this.page_id + "/edit?in=cnarration&operation=kill_page"
    $(lien).attr('href', href);
    return true;
  },
  confirmation_destruction_page: "Êtes-vous certain de vouloir DÉTRUIRE DÉFINITIVEMENT cette page ?\n\nLes fichiers seront détruits, la page sera supprimée de sa table des matières et\nde la base de données.\n\nLA PAGE N’EXISTERA PLUS sous aucune forme que ce soit.",

  on_show:function(lien){
    if (this.page_id == ""){
      F.error("Il faut indiquer l'ID de la page à montrer.");
      this.field_id.focus();
      return false
    }
    var href = "page/" + this.page_id + "/show?in=cnarration"
    $(lien).attr('href', href);
    return true;
  },

  // Méthode appelée lorsqu'un livre est choisi
  // On relève la hiérarchie de base des dossiers pour la proposer
  on_choose_book:function(){
    $('input#epage_handler').val('') ;
    this.set_dossier_page();
    this.set_hierarchie_dossiers('/');
  },

  // Méthode appelée lorsqu'un livre est choisi par exemple et
  // que l'on règle le path de base des fichiers
  set_dossier_page:function(book_id){
    var dossier = $('select#epage_livre_id').find('option[value="'+book_id+'"]').attr("data-folder");
    $('span#dossier_page').html(dossier);
  },

  // Permet de régler le menu des sous-dossiers du livre
  // choisi en les prenant sur l'ordinateur
  set_hierarchie_dossiers:function(from, rajax){
    if(undefined == rajax){
      Ajax.send({
        url: "cnarration/folders",
        from: from,
        book_id: this.livre_id,
        onreturn: $.proxy(Cnarration, 'set_hierarchie_dossiers', from)
      })
    }else{
      // Retour de la relève
      var hier = rajax.hierarchie ;
      if(hier == "") hier = [];
      else{hier = hier.split('::')}
      // +hier+ est maintenant la liste des noms de dossiers
      // On va peupler le menu avec cette liste de dossier pour
      // pouvoir en choisir une
      var menu = $('select#noms_dossiers');
      menu.html('<option value="">Choisir le dossier…</option>');
      $(hier).each(function(i, e){
        menu.append("<option value='"+e+"'>"+e+'</option>')
      })
    }
  },

  // Méthode appelée quand on choisit un dossier dans la liste
  // des noms de dossiers actuels
  // Cela produit l'écriture du dossier au bout de la path
  // du fichier et ça demande le chargement de la liste des
  // dossiers de ce dossier, if any
  on_choose_folder_name:function(){
    var folder_name = $('select#noms_dossiers').val();
    var handler_field = $('input#epage_handler') ;
    var handler = handler_field.val().trim() ;
    handler += folder_name  + "/";
    handler_field.val(handler) ;
    handler_field.focus();
    // Et on actualise le menu du dossier avec les nouvelles
    // valeurs
    this.set_hierarchie_dossiers("/" + handler);
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
  },

  // Méthode appelée quand on change le niveau de
  // développement de la page. Permet d'afficher le
  // menu pour le state de la tâche, pour déterminer si
  // c'est une tâche urgente ou non
  on_change_niveau_developpement:function(niv){
    var is_lecture = niv == 6 || niv == 8 ;
    $('select#epage_tache_state').css('visibility', is_lecture ? 'visible' : 'hidden');
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

$(document).ready(function(){

  // Par défaut, quand on clique sur la touche retour alors que
  // l'on est dans un champ du formulaire #form_edit_page, ça
  // provoque l'enregistrement de la page, ce qui est "dangereux"
  // quand on a changé l'ID pour éditer une autre page.
  // Par prudence, par défaut, quand on clique sur la touche
  // retour, ça ne fera rien
  $('form#form_edit_page').bind('keypress', function(evt){
    if(evt.keyCode == 13){
      evt.stopPropagation();
      evt.preventDefault();
      F.show("Par prudence, la touche retour ne peut pas être utilisée.");
      return false;
    }
  })

  $('select#epage_nivdev').bind('change',function(){Cnarration.on_change_niveau_developpement(parseInt($(this).val()))})

})
