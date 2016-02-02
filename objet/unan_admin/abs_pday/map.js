if(undefined == window.PDays){window.PDays = {}}

$.extend(window.PDays,{

  current: null,

  onclick:function(o){
    if(this.current){this.desactivate(this.current)}
    o = $(o);
    var pday_id = o.attr('data-id');
    var div = $("div#pday-"+pday_id)
    div.hasClass('actived') ? this.desactivate(div) : this.activate(div);
    this.current = div ;
  },
  activate    :function(div){div.addClass('actived')},
  desactivate :function(div){div.removeClass('actived')}

})
