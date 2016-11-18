window.Scenes = {

  // Pour connaitre la liste des scènes "ouvertes" c'est-à-dire les
  // scènes qui affichent la liste des brins.
  collapsed: {},

  /**
    * Actualisation de la liste des brins de la scène ou du paragraphe
    * lorsqu'il ou elle est déployé
    */
  update_scene_if_collapsed:function(sceneparag_id){
    var my = Scenes;
    var osceneparag = $("div#"+sceneparag_id) ;
    if(my.collapsed[sceneparag_id]){
      delete my.collapsed[sceneparag_id];
      osceneparag.find('div.brins').remove();
      my.toggle(null, osceneparag);
    }
  },

  /**
    * Ouverture ou fermeture du paragraphe
    */
  toggle:function(ev, osceneparag){
    // console.log(osceneparag);
    var my = Scenes;
    if(undefined == osceneparag){osceneparag = $(this)}
    var sceneparag_id = osceneparag.attr('id');

    if(my.collapsed[sceneparag_id]){

      // On doit fermer la scène ou le paragraphe

      delete my.collapsed[sceneparag_id];
      osceneparag.find('div.brins').remove();

    }else{

      // On doit ouvrir la scène ou le paragraphe pour montrer tous les brins

      var brins = $('input#'+sceneparag_id+'-brins').val();
      brins = brins.split(' ');
      osceneparag.append('<div class="brins"></div>');
      var div_brins = osceneparag.find('div.brins');
      for(var bi in brins){
        brin_id = brins[bi];
        var clone = $('div#brin-'+brin_id).clone();
        clone.attr('id', clone.attr('id')+'-clone');
        clone.attr('class', 'brin');
        clone.attr('style', '');
        div_brins.append(clone);
      }
      my.collapsed[sceneparag_id] = true;
    }
  }
}

$(document).ready(function(){

  // À faire quand la page est chargée
  $('div.brin').draggable({
    axis: 'y',
    // containment: $('body'),
    // addClasses  : true,
    // appendTo    : '#scenes .scene',
    // scope    : '.scene',
    scroll: false,
    revert: true // pour qu'il revienne après le déplacement
  })

  $('div.contbrins').click(Scenes.toggle)
  $('div.contbrins').droppable({
    accept: '.brin',
    hoverClass: 'hovered',
    drop:function(ev, ui){
      // La div de la scène
      var osceneparag = $(this);
      // L'identifiant de la scène
      var scene_div_id = osceneparag.attr('id') ;
      // Le div du brin qu'on vient de glisser sur la scène
      var obrin = ui.draggable;
      // Le champ hidden de la scène, qui consigne les brins
      var hidden_brins_id = scene_div_id + '-brins';
      var obrins = $('input#'+hidden_brins_id);
      // Le span qui affiche les brins
      var ospanbrins = $('span#'+scene_div_id+'-spanbrins')

      // alert("J'ai lâché le brin #" + obrin.attr('id') + ' sur la scène #'+$(this).attr('id'))
      var brin_id = obrin.attr('id').split('-')[1];
      var brins = obrins.val();
      brins = brins.split(' ');
      offset_brin = brins.indexOf(brin_id);
      // Si le brin n'appartient pas à la liste, il faut
      // l'ajouter, sinon, il faut le retirer
      if (offset_brin < 0){brins.push(brin_id)}
      else{brins.splice(offset_brin, 1)}
      brins = brins.join(' ');
      obrins.val(brins);
      ospanbrins.html(brins);
      // Si la scène est "ouverte", on doit actualiser sa liste
      // de brins affichée.
      Scenes.update_scene_if_collapsed(scene_div_id);
    }
  })

  UI.bloquer_la_page(true);

})//onready
