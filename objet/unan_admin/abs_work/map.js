if(undefined==window.MapWorks){window.MapWorks = {}}

$.extend(window.MapWorks, {

  current_work_id: null,

  on_click_work:function(ev){
    if(MapWorks.blocked){
      return;
    } else {
      MapWorks.blocked = true ;
      MapWorks.timer = setTimeout($.proxy(MapWorks,'unblocked'), 300) ;
    }
    if(MapWorks.current_work_id){
      var div_jid = 'div#'+MapWorks.current_work_id;
      $(div_jid).removeClass('selected');
    }
    var o   = $(this).clone() ;
    var id  = o.attr('id') ;
    // console.log("id = " + id);
    if (id == MapWorks.current_work_id){
      $('div#overview_infos_work').html('');
      MapWorks.current_work_id = null ;
    }else{
      o.attr('style', '') ;
      var a = o.find('> a')
      a.attr('href', a.attr('data-href')).attr('onclick', 'return true');
      $('div#overview_infos_work').html('').append(o) ;
      MapWorks.current_work_id = id ;
      $(this).addClass('selected');
    }
  },
  unblocked:function(){
    clearTimeout(MapWorks.timer);
    MapWorks.blocked = false ;
  },

  // Méthode appelée en survolant les div des travaux
  // Cela doit afficher leur clone dans la partie
  // appropriée
  on_hover_work:function(ev){
    // var o = $(this).clone();
    // o.attr('style', "") ;
    // $('div#overview_infos_work').html('').append( o );

  },

  // Pour placer les observeurs qui vont réagir au click
  // sur un travail, pour changer son style et pouvoir l'afficher
  observe_works:function(){
    $('div.work').bind('click', MapWorks.on_click_work);
    // $('div.work').bind('mouseover', MapWorks.on_hover_work);
  },

  prepare_interface: function(){
    this.observe_works();
    $('div.work > a').each(function(){
      var o = $(this);
      var href = o.attr('href');
      o.attr('href', 'javascript:void(0)');
      o.attr('data-href', href);
      o.attr('onclick', 'return false;')
    })
  }
})
Object.defineProperties(window.MapWorks, {

})
$(document).ready(function(){
  window.MapWorks.prepare_interface();
  window.MapWorks.observe_works();
})
