if(undefined==window.MapWorks){window.MapWorks = {}}

$.extend(window.MapWorks, {

  on_click_work:function(ev){
    // var o = $(this);
    // if(o.hasClass('collapsed')){
    //   o.removeClass('collapsed')
    // }else{
    //   o.addClass('collapsed')
    // }
  },

  // Méthode appelée en survolant les div des travaux
  // Cela doit afficher leur clone dans la partie
  // appropriée
  on_hover_work:function(ev){
    var o = $(this).clone();
    o.attr('style', "") ;
    $('div#overview_infos_work').html('').append( o );

  },

  // Pour placer les observeurs qui vont réagir au click
  // sur un travail, pour changer son style et pouvoir l'afficher
  observe_works:function(){
    $('div.work').bind('click', MapWorks.on_click_work);
    $('div.work').bind('mouseover', MapWorks.on_hover_work);
  }
})
Object.defineProperties(window.MapWorks, {

})
$(document).ready(function(){
  window.MapWorks.observe_works();
})
