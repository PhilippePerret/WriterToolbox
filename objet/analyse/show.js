// Raccourci pour utiliser seulement `s(num scène)` dans les
// attributs onclick
function s(numero){Scenes.show(numero)}

if(undefined==window.Scenes){window.Scenes={}}
$.extend(window.Scenes,{

  // Liste de toutes les scènes actuellement sélectionées,
  // avec leurs informations, par exemple leur couleur
  // originale
  selected: {},

  // Pour l'affichage d'une scène dans le scénier
  // +numero+ peut être un numéro seul ou une liste de numéros
  // de scènes
  show:function(numeros){
    // Au cas où, il faut toujours ouvrir la timeline
    this.open_timeline();
    if ('number' == typeof numeros){numeros = [numeros]}
    // On commence par déselectionner les scènes qui le sont
    for(var i in this.selected){
      this.deselect_scene( this.selected[i] ) ;
    }
    // On sélectionne les scènes demandées
    for(var i in numeros){
      this.select_scene(numeros[i]);
    }
    // On se rend toujours à la première scène
    if( numeros[0] ){ this.goto_scene(numeros[0]) }
  },
  goto_scene:function(numero){
    var o = $('div#scenier_dynamique div#scv-'+numero) ;
    // Le décalage de la scène par rapport au haut
    var toppos = o[0].offsetTop ;
    var tl = $('div#scenier_dynamique div.timeline-v');
    // On scrolle jusqu'à l'élément, avec 40 pixels en moins
    // pour qu'il ne commence pas tout au-dessus, ce qui le
    // situerait en dessous en la timeline horizontale
    tl.scrollTop(toppos - 40);
  },
  select_scene:function(numero){
    // Objet de la scène dans la timeline verticale
    var ov = $('div#scenier_dynamique div.timeline-v div#scv-'+numero+'.sc');
    // Objet de la scène dans la timeline horizontale
    var oh = $('div#scenier_dynamique div.timeline-h div#sch-'+numero+'.sc');
    this.selected[numero] = {
      numero: numero,
      bgcolor: oh.css('background-color'),
      opacity: oh.css('opacity'),
      objet_v: ov,
      objet_h: oh
    }
    console.dir(numero);
    console.dir(this.selected[numero]);
    oh.css({
      'opacity'           : 1,
      'background-color'  : 'red',
      'height'            : '50px',
      'top'               : '-10px'
    })
    ov.css({
      'opacity'           : 1
    })

  },
  deselect_scene:function( dscene ){
    if('number' == typeof dscene){ dscene = this.selected[ dscene ] }

    dscene.objet_h.css({
      'opacity' : dscene.opacity,
      'background-color': dscene['background-color'],
      'height'  : '32px',
      'top'     : '0'});
    dscene.objet_v.css({'opacity':'0.7'})
    delete this.selected[dscene.numero] ;
  },

  close_timeline:function(){
    $('div#scenier_dynamique').hide();
  },
  open_timeline:function(){
    $('div#scenier_dynamique').show();
  }
})

$(document).ready(function(){
  $('div#scenier_dynamique').draggable();
})
