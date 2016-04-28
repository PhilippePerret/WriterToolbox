if(undefined==window.MapWorks){window.MapWorks = {}}

$.extend(window.MapWorks, {

  // Appelé quand le document est prêt, pour bloquer
  // la page, qui ne pourra plus que se déplacer horizontalement
  bloquer_la_page:function(){
    // UI.bloquer_la_page(true);
    // $('section#content').css({
    //   'position':(bloquer ? 'fixed' : 'relative'),
    //   'top':(bloquer ? '0' : 'none')
    // })
    // $('section#content').css({
    //   'margin-left':'10px',
    //   'padding-left':'0',
    //   'position': 'absolute',
    //   'left':'auto'
    // })
    // // Cacher les titres (pour remonter le tableau)
    // var los = ['form#taches_widget', 'section#content h1',
    //   'section#content h2'];
    //
    // $(los).each(function(i,e){$(e).hide()});
  },

  on_click_work:function(ev){
    var o = $(this);
    if(o.hasClass('collapsed')){
      o.removeClass('collapsed')
    }else{
      o.addClass('collapsed')
    }
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
