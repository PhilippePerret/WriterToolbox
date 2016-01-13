if(undefined == window.UI){window.UI={}}
$.extend(window.UI,{

  // Prépare les champs input-text et textarea pour que
  // lorsqu'on focus dedans ils sélectionnent leur contenu
  // À mettre dans le $(document).ready ou lorsque du
  // code est remonté par Ajax.
  auto_selection_text_fields:function(){
    $(['input[type="text"]', 'textarea']).each(function(i, jid){
      // Au cas où…
      $(jid).unbind('focus', function(){$(this).select()})
      // On le surveille
      $(jid).bind('focus', function(){$(this).select()})
    })
  },

  // Observe tous les champs d'édition qui possède une
  // class 'warning'. Ce sont des champs mis en exergue
  // peut-être suite à une erreur ou une valeur incorrecte.
  // Quand l'utilisateur le modifie, on peut supprimer la
  // classe
  observe_champs_warning:function(){
    $(['input.warning', 'textarea.warning', 'select.warning']).each(function(i,o){
      $(o).bind('change', function(){$(this).removeClass('warning')})
    })
  }

})
