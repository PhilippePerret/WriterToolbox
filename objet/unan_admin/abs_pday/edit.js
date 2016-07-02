if(undefined == window.AbsPDay){window.AbsPDay = {}}

$.extend(window.AbsPDay,{

  // Initialisation du formulaire (pour nouveau jourprogramme)
  init_new:function(){
    var champs_valeurs = [
      'input#pday_id',
      'input#pday_titre',
      'input#pday_works',
      'input#minimum_points',
      'textarea#pday_description'
    ];
    var champs_select = [
    ]
    var champs_uncheck = [
    ]
    var champs_vide_html = [
    ]
    var champs_to_remove = [
      'ul#linked_works'
    ]
    UI.init_form({
      val:      champs_valeurs,
      select:   champs_select,
      uncheck:  champs_uncheck,
      empty:    champs_vide_html,
      remove:   champs_to_remove
    })
  }
})


$(document).ready(function(){

  // Le code pour rendre les textareas sensibles aux
  // Snippets
  Snippets.set_scopes_to([
    'text.erb', 'text.html'
  ]);
  $('textarea').bind('focus',function(){Snippets.watch(($(this)))})
  $('textarea').bind('blur',function(){Snippets.unwatch(($(this)))})


})
