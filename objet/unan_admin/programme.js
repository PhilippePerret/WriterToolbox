if(undefined == window.MapProgramme){window.MapProgramme = {}}
$.extend(window.MapProgramme,{

  /**
    * Méthode pour ouvrir/fermer les items d'un élément
    */
  toggle: function(o){
    $(o).next().toggle();
  },

  /**
    * Méthode appelée pour afficher un jour particulier ou un
    * segment particulier de jour-programme.
    * Ou autre élément désigné par le contenu de input#jp
    *
    * Noter que ça permet d'afficher des choses qu'on ne peut pas
    * faire "à la main" grâce au système de filtre.
    */
  show_jp: function(){
    var jp_seg = $('input#jp').val();

    switch(jp_seg){
      case 'TODO', 'todo' :
        this.show_lines_todo();break;
      default:
        this.show_jours_programmes(jp_seg)
    }
  },

  /** Méthode qui va afficher dans le plan du programme toutes les
    * lignes définissant quelque chose à faire.
    * Ces lignes sont repérées par la classe linep.todo
    *
    * Principe : On trouve le ligne puis on ouvre tous ses parents
    */
  show_lines_todo: function(){
    var lines = $('div#programme_map div.linep.todo')
    var nombre_lines = lines.length;
    var css;
    if(nombre_lines){
      F.show(nombre_lines + " lignes trouvées.");
      lines.each(function(){
        var o = $(this);
        o.show();
        var dady = o;
        while(dady = dady.parent()){
          css = dady.attr('class');
          if(undefined == css){break}
          var is_div_items = css.indexOf('items') > -1;
          var is_div_linep = css.indexOf('linep') > -1;
          if(is_div_items || is_div_linep){ dady.show()}
          else{break}
        }
      })
    }else{
      F.show('Aucune ligne trouvée.')
    }
  },
  show_jours_programmes:function(jp_seg){

    jp_seg = jp_seg.split('-');
    var jp_deb = parseInt(jp_seg[0], 10);
    var jp_fin = parseInt(jp_seg[1], 10);
    if(isNaN(jp_deb) || jp_deb < 1){
      return F.error('Il faut indiquer un nombre supérieur à 0 comme jour-programme de départ.')
    }
    if(jp_fin){
      if(isNaN(jp_fin)){return F.error('Il faut indiquer un nombre comme jour-programme de fin.')}
      if(jp_fin < jp_deb){return F.error('Le jour-programme de fin devrait être supérieur au jour de départ.')}
    } else {
      jp_fin = jp_deb ;
    }

    // On parcours d'arbre en cherchant les jours ou le jour
    $('div#programme_map div.linep[data-jp]').each(function(){
      var odiv = $(this);
      var data_jp = odiv.attr('data-jp');
      data_jp = data_jp.split('-');
      var data_jp_deb = parseInt(data_jp[0], 10);
      var data_jp_fin = parseInt(data_jp[1], 10);
      var isGood ;
      if(data_jp_fin){
        // Si cette ligne définit un segment
        isGood = data_jp_deb < jp_fin && data_jp_fin > jp_deb
      } else {
        // Si cette ligne ne définit qu'un seul jour, il faut
        // que ce jour appartienne au segment
        isGood = data_jp_deb >= jp_deb && data_jp_deb <= jp_fin
      }

      // Si cette ligne est bonne, on l'affiche, sinon, on la masque
      if(isGood){
        odiv.show();
        odiv.find('> div.items').show();
      }else{
        odiv.hide();
        odiv.find('> div.items').hide();
      }
    })
  }
})