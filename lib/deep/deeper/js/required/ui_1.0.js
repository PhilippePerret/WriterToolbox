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
  },

  /** Pour initialiser les champs d'un formulaire
    * +hfields+ est un Hash pouvant contenir au choix :
    *   .val      Array des JID de champs dont la valeur (value) doit
    *             être mise à "".
    *   .uncheck  Array des ID (attention, pas JID) des checkbox qui
    *             doivent être décochés
    *   .check    Array des ID (attention, pas JID) des checkbox qui
    *             doivent être cochés
    *   .empty    Array des JID des champs dont le contenu (html) doit
    *             être vidé
    *   .select   Array des ID (pas JID) des menus qui doivent être
    *             remis à la valeur 0
    */
  init_form:function(hfields){
    if(hfields.val)
      $(hfields.val).each(function(i, o){console.log(i);$(o).val('')});
    if(hfields.uncheck)
      $(hfields.uncheck).each(function(i,o){$("input#"+o)[0].checked = false});
    if(hfields.check)
      $(hfields.check).each(function(i,o){$("input#"+o)[0].checked = true});
    if(hfields.empty)
      $(hfields.empty).each(function(i,o){$(o).html('')});
    if(hfields.select)
      $(hfields.select).each(function(i,o){$('select#'+o)[0].selectedIndex = 0});
  }


})
