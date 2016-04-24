if(undefined == window.UI){window.UI = {}}

$.extend(window.UI,{

  /** Méthode permettant de bloquer la page, i.e. de rendre
    * la section#content fixe et de faire disparaitre les
    * éléments de page inutiles.
    * Utile pour les listes qui sont toujours embêtantes
    * à utiliser.
    */
  bloquer_la_page:function(bloquer){
    $('section#content').css({
      'position':(bloquer ? 'fixed' : 'relative'),
      'top':(bloquer ? '0' : 'none')
    })
    $([
      'section#header',
      'section#footer',
      'section#debug',
      'section#left_margin', 'div#chapiteau_logo']).each(function(i,e){
        if(bloquer){ $(e).hide()}
        else{$(e).show()}
    })
  }

})
