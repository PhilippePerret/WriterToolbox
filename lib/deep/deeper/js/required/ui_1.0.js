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
  }

})
