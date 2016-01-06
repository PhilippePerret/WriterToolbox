$(document).ready(function(){
  var ot = $('textarea#console')

  ot.bind('keypress', function(e){
    switch(e.keyCode){
      case 13:
        $(this)[0].form.submit();
        e.stopPropagation();
        e.preventDefault();
        return false;
    }
  });
  // À chaque chargement on focusse à la fin du textarea pour
  // poursuivre le code
  ot.focus();
  var offset_end = ot.val().length;
  Selection.select(ot, {start:offset_end, end: offset_end})

})
