if(undefined == window.Prefs){window.Prefs = {}}

$.extend(window.Prefs,{

  // Méthode appelée quand on coche ou décoche la case
  // pour envoyer le mail quotidien à heure fixe
  on_check_fixed_time: function(o){
    var m = $('span#span_fixed_time') ;
    m.css('visibility', o.checked ? 'visible' : 'hidden');
  }
})
