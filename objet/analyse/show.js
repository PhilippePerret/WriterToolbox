// Raccourci pour utiliser seulement `s(num scène)` dans les
// attributs onclick
function s(numero){Scenes.show(numero)}
function sv(numero){Scenes.show_in_timelinev(numero)}

if(undefined==window.Scenes){window.Scenes={}}
$.extend(window.Scenes,{

  // Liste de toutes les scènes actuellement sélectionées,
  // avec leurs informations, par exemple leur couleur
  // originale
  selected: {},
  // Liste simplement des numéros des scènes sélectionnées
  // Elle sert principalement pour se déplacer de scènes
  // en scènes à l'aide de la boite de navigation
  selection_courante: null,
  // Indice de la scène courante sélectionnée
  iscene_selection_courante: null,


  // Pour l'affichage d'une scène dans le scénier
  // +numero+ peut être :
  //  - {Number} un numéro seul
  //  - {Object} une liste Array de numéros de scènes
  //  - {String} un string avec les numéros séparés par des espaces
  show:function(numeros){

    // Au cas où, il faut toujours ouvrir la timeline
    this.open_timeline();

    // Au cas où on clique sur une autre liste de scènes ou
    // scène dans le texte alors que la timeline est encore
    // ouverte, il faut s'initialiser
    this.reset();

    // Déterminer la liste des numéros
    if ('number' == typeof numeros){numeros = [numeros]}
    else if ('string' == typeof numeros){numeros = numeros.split(' ')}

    // On sélectionne les scènes demandées
    for(var i in numeros){
      numeros[i] = parseInt(numeros[i]) ;
      this.select_scene(numeros[i]);
    }
    // On se rend toujours à la première scène
    if( numeros[0] ){ this.goto_scene(numeros[0]) }

    // S'il y a plusieurs scènes, il faut afficher la boite
    // de navigation scène par scène
    var plusieurs_scenes = numeros.length > 1 ;
    var onav = $('div#timeline_scenes_boite_navigation_selection')
    if( plusieurs_scenes ){
      onav.show();
      this.iscene_selection_courante = 0 ;
      this.selection_courante = numeros ;
      this.select_current_scene() ;
    } else {
      onav.hide();
    }
  },


  // Sélectionne la scène précédente dans la sélection
  // de scènes courante
  select_prev:function(){
    if( this.iscene_selection_courante == 0 ) return ;
    this.iscene_selection_courante -= 1 ;
    this.select_current_scene();
  },
  // Sélectionne la scène suivante dans la sélection de
  // scènes courante
  select_next: function(){
    if(this.iscene_selection_courante == this.selection_courante.length - 1) return ;
    this.iscene_selection_courante += 1 ;
    this.select_current_scene();
  },
  // Sélectionne la scène iscene_selection_courante dans la
  // timeline verticale et indique son numéro dans la boite
  // de navigation dans la sélection
  select_current_scene:function(){
    var numero_current_scene = parseInt( this.selection_courante[this.iscene_selection_courante] );
    this.show_in_timelinev(numero_current_scene);
    this.set_numero_current_scene( numero_current_scene) ;
    // On doit indiquer la couleur de fond en bleu et retirer
    // la couleur en bleue de la scène précédente
    if(this.last_selection_courante){
      $('div#sch-'+this.last_selection_courante).css('background-color', 'red');
    }
    // Dans tous les cas on sélectionne la scène courante en
    // bleu
    $('div#sch-'+numero_current_scene).css('background-color', 'blue');
    this.last_selection_courante = 0 + numero_current_scene ;
    // Visibilité des boutons scène suivante ou précédente
    var bouton_prev_visible = this.iscene_selection_courante > 0 ;
    var bouton_next_visible = this.iscene_selection_courante < (this.selection_courante.length - 1) ;
    var visu_btn_prev = bouton_prev_visible ? 'visible' : 'hidden' ;
    $('a#btn_prev_scene_timeline').css('visibility', visu_btn_prev) ;
    $('a#btn_next_scene_timeline').css('visibility', bouton_next_visible ? 'visible' : 'hidden') ;
  },

  // Indiquer le numéro de la scène courante dans la boite
  // de navigation de sélection (scènes sélectionnées)
  set_numero_current_scene:function( numero ){
    this.span_numero_current_scene().html("Scène " + numero);
  },
  span_numero_current_scene:function(){
    return $('div#timeline_scenes_boite_navigation_selection span#numero_scene_courante') ;
  },
  // Sélectionne la scène dans la timeline vertical
  //
  // La méthode est utilisée pour sélectionner la
  // scène quand on clique sur la timeline horizontale,
  // en passant par la méthode `sv`
  show_in_timelinev:function(numero){
    this.goto_scene(numero);
    var i, e ;
    for(i = numero-10; i<numero+10; ++i){
      e = $('div#timeline_scenes div.timeline-v div#scv-'+i) ;
      e.css('opacity', i == numero ? '1' : '0.7')
    }
  },
  goto_scene:function(numero){
    var o = $('div#timeline_scenes div#scv-'+numero) ;
    // Le décalage de la scène par rapport au haut
    var toppos = o[0].offsetTop ;
    var tl = $('div#timeline_scenes div.timeline-v');
    // On scrolle jusqu'à l'élément, avec 40 pixels en moins
    // pour qu'il ne commence pas tout au-dessus, ce qui le
    // situerait en dessous en la timeline horizontale
    tl.scrollTop(toppos - 40);
  },
  select_scene:function(numero){
    numero = parseInt(numero) ;
    // Objet de la scène dans la timeline verticale
    var ov = $('div#timeline_scenes div.timeline-v div#scv-'+numero);
    // Objet de la scène dans la timeline horizontale
    var oh = $('div#timeline_scenes div.timeline-h div#sch-'+numero);
    this.selected[numero] = {
      numero: numero,
      bgcolor: oh.css('background-color'),
      opacity: oh.css('opacity'),
      objet_v: ov,
      objet_h: oh
    }
    oh.css({
      'opacity'           : 1,
      'background-color'  : 'red',
      'height'            : '40px',
      'top'               : '-4px'
    })
    ov.css({
      'opacity'           : 1
    })

  },
  deselect_scene:function( dscene ){
    if('number' == typeof dscene){ dscene = this.selected[ dscene ] }

    dscene.objet_h.css({
      'opacity'         : dscene.opacity,
      'background-color': dscene.bgcolor,
      'height'          : '32px',
      'top'             : '0'});
    dscene.objet_v.css({'opacity':'0.7'})
    delete this.selected[dscene.numero] ;
  },

  // On ré-initialise tout pour que la timeline soit pure
  // comme au premier jour.
  reset: function(){
    var my = this ;
    $('div#timeline_scenes div.timeline-h div.sc').each(function(){
      var id     = parseInt( $(this).attr('id').split('-')[1] ) ;
      var dscene = my.selected[id] ;
      if(undefined != dscene){ my.deselect_scene(dscene)}
      // Dans tous les cas, on remet les valeurs de base
      // (note : la ligne deselect_scene ci-dessus sert uniquement
      // pour régler la couleur de fond de la scène)
      $(this).css({
        'opacity' : '0.5',
        'height'  : '32px',
        'top'     : '0'
      })
    })
    this.last_selection_courante    = null ;
    this.selection_courante         = null ;
    this.iscene_selection_courante  = null ;
    this.selected = {} ;
  },

  close_timeline:function(){
    this.reset();
    $('div#timeline_scenes').hide();
  },
  open_timeline:function(){
    $('div#timeline_scenes').show();
  }
})

$(document).ready(function(){
  $('div#timeline_scenes').draggable();
})
