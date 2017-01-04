
// N0005
window.common_key_press_shortcuts = function(ev){
  // if(console){
  //   console.clear();
  //   console.log(
  //     'ctrlKey:'+ev.ctrlKey + ' metaKey:'+ev.metaKey + ' / altKey:'+ev.altKey + ' / shiftKey:'+ev.shiftKey +
  //     "\ncharCode = " + ev.charCode + ' / keyCode = ' + ev.keyCode
  //   );
  // }
  if(ev.ctrlKey){
    switch(ev.charCode){
      case 97:
        // CTRL + A => afficher/masquer l'aide
        Collector.aide();
        break;
      case 98:
        // CTRL + B => affiche brins (liste ou data)
        DataField.show_or_new(Brins);
        break;
      // CTRL + P => affiche personnages (liste ou data)
      case 112:
        DataField.show_or_new(Persos);
        break;
      default: return true;
    }
    return stop_event(ev);
  }
}

window_on_key_press = function(ev){
  if(false == window.common_key_press_shortcuts(ev)){return false}
  // if(ev.ctrlKey){
  //   switch(ev.charCode){
  //     case 97:
  //       Collector.aide();
  //       break;
  //     case 113:
  //       F.show('P')
  //       break;
  //     default: return true;
  //   }
  //   return stop_event(ev);
  // }
}

$(document).ready(function(){

  Collector.initialize();

  // Tous les éléments DataField à initialiser
  // cf. _REFBOOK_.md
  DataField.initialize(Persos);
  DataField.initialize(Brins);

  UI.bloquer_la_page(true, {minimize_textarea: false});
  window.onkeypress = window_on_key_press;

})
