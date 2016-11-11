

$(document).ready(function(){

  // À faire quand la page est chargée
  $('div.brin').draggable({
    axis: 'y',
    // containment: $('body'),
    // addClasses  : true,
    // appendTo    : '#scenes .scene',
    // scope    : '.scene',
    revert: true // pour qu'il revienne après le déplacement
  })

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
      console.log("Brins avant : "+obrins.val());
      brins = brins.split(' ');
      if (brins.indexOf(brin_id) < 0){
        brins.push(brin_id)
        brins = brins.join(' ')
        obrins.val(brins);
        ospanbrins.html(brins);
      }

      console.log("Brins après : "+obrins.val());
    }
  })
})
