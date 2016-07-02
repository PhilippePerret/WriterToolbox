function on_change_type_general_travail(value){
  if(undefined == value){ value = $('select#work_typeW')[0].value }
  // Avant, on masquait/affichait le div pour les pages
  // cours ou les questionnaires, mais maintenant on fonctionne
  // avec un `item_id` donc ça n'est plus utile.
}
if(undefined == window.AbsWork){window.AbsWork = {}}

$.extend(window.AbsWork,{

  // Initialisation du formulaire (pour nouveau travail)
  init_new:function(){
    window.location.href = 'abs_work/edit?in=unan_admin';
  }

});

$(document).ready(function(){

  // Le code pour rendre les textareas sensibles aux
  // Snippets
  Snippets.set_scopes_to([
    'text.erb', 'text.html'
  ]);
  $('textarea').bind('focus',function(){Snippets.watch(($(this)))})
  $('textarea').bind('blur',function(){Snippets.unwatch(($(this)))})


})
