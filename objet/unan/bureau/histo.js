if(undefined == window.UnanHisto){window.UnanHisto={}}
$.extend(window.UnanHisto,{
  show:function(olien){
    var li_id = $(olien).attr('data-id');
    li_id = "li_work-" + li_id;
    var div = $('li#'+li_id+' > div.hinfos')
    if(div.hasClass('masked')){div.removeClass('masked')}
    else{div.addClass('masked')}
  }
})
