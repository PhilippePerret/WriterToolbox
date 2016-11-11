window.Scenes = {

  // Pour connaitre la liste des scènes "ouvertes" c'est-à-dire les
  // scènes qui affichent la liste des brins.
  collapsed: {},

  update_scene_if_collapsed:function(scene_id){
    var my = Scenes;
    var oscene = $("div#"+scene_id) ;
    if(my.collapsed[scene_id]){
      delete my.collapsed[scene_id];
      oscene.find('div.brins').remove();
      my.toggle(null, oscene);
    }
  },

  toggle:function(ev, oscene){
    // console.log(oscene);
    var my = Scenes;
    if(undefined == oscene){oscene = $(this)}
    var scene_id = oscene.attr('id');
    if(my.collapsed[scene_id]){

      // On doit fermer la scène

      delete my.collapsed[scene_id];
      oscene.find('div.brins').remove();

    }else{

      // On doit ouvrir la scène pour montrer tous les brins

      var brins = $('input#'+scene_id+'-brins').val();
      brins = brins.split(' ');
      oscene.append('<div class="brins"></div>');
      var div_brins = oscene.find('div.brins');
      for(var bi in brins){
        brin_id = brins[bi];
        var clone = $('div#brin-'+brin_id).clone();
        clone.attr('id', clone.attr('id')+'-clone');
        clone.attr('class', 'brin');
        clone.attr('style', '');
        div_brins.append(clone);
      }
      my.collapsed[scene_id] = true;
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

  $('div.scene').click(Scenes.toggle)
  $('div.scene').droppable({
    accept: '.brin',
    hoverClass: 'hovered',
    drop:function(ev, ui){
      // La div de la scène
      var oscene = $(this);
      // L'identifiant de la scène
      var scene_div_id = oscene.attr('id') ;
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
