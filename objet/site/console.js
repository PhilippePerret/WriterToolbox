$(document).ready(function(){
  $('textarea#console').bind('keypress', function(e){
    switch(e.keyCode){
      case 13:
        $(this)[0].form.submit();
        e.stopPropagation();
        e.preventDefault();
        return false;
        break;
    }
  })
})
