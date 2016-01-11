$(document).ready(function(){
  if($('#flash').length){
    var coefH = $('#flash').height() / 40;
    setTimeout($.proxy(Flash, 'clean', null, true), 5000 * coefH)
  }
  UI.auto_selection_text_fields();

})
