window.TSynchro = {


  on_ope:function(alink){

    var reload  = $('input[type="checkbox"]#reload_distant_taches')[0].checked ;
    var keep    = $('input[type="checkbox"]#keep_distant_taches')[0].checked ;
    var href = $(alink).attr('href') ;
    href += "&reload="  + (reload ? '1' : '0')
    href += "&keep="    + (keep ? '1' : '0')
    $(alink).attr('href', href) ;
    return true ;
  }

}
