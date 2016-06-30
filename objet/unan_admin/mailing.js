if(undefined == window.Mailing){window.Mailing = {}}

$.extend(window.Mailing, {

  on_check_memorize_as_mtype:function(ocb){
    $('div#div_mtype_titre')[ocb.checked ? 'show' : 'hide']();
  }
})
