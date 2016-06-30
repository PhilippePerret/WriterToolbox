if(undefined == window.UnanAdmin){window.UnanAdmin = {}}

$.extend(window.UnanAdmin, {

  on_check_memorize_as_mtype:function(ocb){
    $('div#div_mtype_titre')[ocb.checked ? 'show' : 'hide']();
  }
})
