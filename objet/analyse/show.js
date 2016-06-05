// Raccourci pour utiliser seulement `s(num scène)` dans les
// attributs onclick
function s(numero){Scenes.show(numero)}
function sv(numero){Scenes.show_in_timelinev(numero)}

if(undefined==window.PFA){window.PFA={}}
$.extend(window.PFA, {
  CALQUE: null, // réglé par l'init de Scenes
  CADRE: null,
  displayed: false,
  toggle:function(){
    if(this.displayed){this.hide()} else { this.show() }
    this.displayed = !this.displayed ;
  },
  show:function(){
    $('a#tls_toggle_pfa').addClass('actived') ;
    $('div#tls_pfa_tools_nav').css('visibility', 'visible');
    this.CALQUE.show();
  },
  hide:function(){
    $('a#tls_toggle_pfa').removeClass('actived') ;
    $('div#tls_pfa_tools_nav').css('visibility', 'hidden');
    this.CALQUE.hide();
  },

  inode: null, // L'index 0-start du noeud courant
  // Numéro de la scène courante dans le noeud courant
  // Principe : On avance de scène en scène jusqu'à ce que
  // le temps limite du noeud courant soit atteint. Si c'est le
  // cas, on passe au nœud suivant, sinon, on passe à la scène
  // suivante
  scene_num: null,

  vingt4e: 4.16, //8.33,
  DATA_NODE: [
    {hname: "Pivot 1",      fin: 25 },
    {hname: 'Clé de voûte', milieu: 50},
    {hname: "Pivot 2",      fin: 75 }
  ],

  // Pour sélectionner le nœud précédent
  prev_node: function(){
    if(this.inode === null)return;
  },
  // Pour sélectionner le nœud suivant, ou plus exactement
  // la prochaine scène qui correspond soit au nœud courant
  // soit au nœud suivant
  next_node:function(){
    if(this.inode     === null){ this.inode = 0     }
    if(this.scene_num === null){ this.scene_num = 0 }

    // Il faut voir s'il faut passer à la scène
    // suivante/nœud suivant. Il faut passer au nœud suivant
    // seulement si la scène suivante dépasse le temps
    // voulu

    // Les pourcentages des temps du noeud
    var node_times = function(dnode){
      if(undefined != dnode.fin){
        return [dnode.fin - PFA.vingt4e, dnode.fin ]
      }else if(undefined != dnode.milieu){
        return [dnode.milieu - PFA.vingt4e, dnode.milieu + PFA.vingt4e]
      }else if(undefined != dnode.debut){
        return [dnode.debut, dnode.debut + PFA.vingt4e]
      }
    }(this.DATA_NODE[this.inode]);
    // On transforme les pourcentages en valeur de temps
    // par rapport au film.
    // Noter aussi qu'on transforme la liste en Hash
    node_times = {
      debut : parseInt((node_times[0]/100) * Scenes.DUREE_FILM),
      fin   : parseInt((node_times[1]/100) * Scenes.DUREE_FILM),
      '(durée film)' : Scenes.DUREE_FILM,
      '(node times)' : node_times
    }

    console.dir(node_times);

    // Si la fin de la scène est inférieure au début du
    // temps du node, il faut passer à la scène suivante
    // jusqu'à ce que la fin de la scène soit comprise
    // dans la zone du noeud.
    do {
      this.scene_num += 1 ;
      // console.log("this.scene_num = " + this.scene_num) ;
      var fin_scene = Scenes.scenes[this.scene_num + 1].time
      // console.log("Scenes.scenes[this.scene_num + 1].time = " + Scenes.scenes[this.scene_num + 1].time);
    } while( fin_scene < node_times.debut );


    // Si le temps de la scène est encore dans l'intervalle
    // voulu, on la montre, sinon, on passe au node suivante
    if ( Scenes.scenes[this.scene_num].time < node_times.fin ){
      Scenes.display(this.scene_num) ;
      $('span#tls_pfa_nav_libelle').html(this.DATA_NODE[this.inode].hname + " ?")
    } else {
      this.inode += 1 ;
      this.next_node() ;
    }

  }

})
if(undefined==window.Scenes){window.Scenes={}}
$.extend(window.Scenes,{

  // Objet DOM (jQuery) de la timeline des scènes
  // C'est le DIV qui contient tous les éléments
  // de la timeline des scènes.
  TIMELINE_SCENES: null,

  // Durée du film en seconde
  //
  DUREE_FILM: null,


  // Largeur du bloc du PFA
  // (sur lequel on glisse la souris)
  PFA_WIDTH: null,

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

  // Initialisation
  inited: false,
  init:function(){
    this.TIMELINE_SCENES    = $('div#timeline_scenes');
    this.TIMELINE_V         = $('div#timeline_scenes div.timeline-v') ;
    this.CALQUE_PFA = PFA.CALQUE = $('div#pfa') ;

    // On les affiche pour prendre leurs dimensions
    this.TIMELINE_SCENES.show();
    this.CALQUE_PFA.show();

    // On fait les calculs
    this.PFA_WIDTH          = this.CALQUE_PFA.width();
    this.PFA_OFFSET_LEFT    = this.CALQUE_PFA.offset().left ;

    this.init_pfa();

    this.DUREE_FILM = parseInt(this.TIMELINE_SCENES.attr('data-film-duree'));
    this.COEF_PIXELS_TO_SECONDS = this.DUREE_FILM / this.TIMELINE_SCENES.find("div#pfa").width();

    // Préparation de la table left->numéro scène
    this.calcule_lefts2scenes();

    this.TIMELINE_SCENES.hide();
    this.CALQUE_PFA.hide();

    this.inited = true ;
  },

  // Méthodes "left-to-second" qui reçoit un offset left et
  // retourne la position en secondes correspondant
  //
  // Cette méthode sert à retourner la position temporelle
  // de la souris quand elle survole la timeline (ou plus
  // exactement le PFA)
  l2s:function(left_pos){
    return parseInt( left_pos * this.COEF_PIXELS_TO_SECONDS );
  },

  // Initialisation du PFA
  //
  // La méthode est appelée lorsque l'on glisse la souris
  // sur le PFA ou lorsqu'on clique le bouton "PFA"
  // Principalement, elle relève les temps de chaque scène
  // pour un usage plus rapide
  pfa_inited: false,
  init_pfa:function(){
    if(this.pfa_inited)return;
    // console.log("-> Scenes.init_pfa");
    this.scenes = {};
    var my = this ;
    this.TIMELINE_SCENES.find('div.timeline-h div.sc').each(function(){
      var o = $(this);
      var sid = parseInt(o.attr('id').split('-')[1]) ;
      var stime = parseInt(o.attr('data-time')) ;
      var stop  = $('div.timeline-v div#scv-' + sid )[0].offsetTop ;
      // Noter qu'on décale déjà de 40 pixels pour avoir le
      // vrai scrollTop qu'il faudra utiliser
      my.scenes[sid] = { time: stime, top: stop - 40} ;
    })
    // console.dir(this.scenes) ;
    this.pfa_inited = true ;
  },

  // Méthodes qui construit la table contenant en clé le
  // décalage left (sur le calque PFA, au survol de la souris) et
  // en valeur le numéro de scène correspondant
  calcule_lefts2scenes:function(){
    var current_numero_scene = 0 ;
    this.lefts2scenes = {} ;
    for(var i = 0; i < this.PFA_WIDTH + 10 ; ++i){
      // Le nombre de secondes auxquels correspond ce
      // pixel +i+
      var seconds = this.l2s(i) ;
      // La scène à laquelle correspond ce nombre de secondes
      if (this.scenes[current_numero_scene + 1] && this.scenes[current_numero_scene + 1].time <= seconds){
        // => On passe à la scène suivant
        current_numero_scene = current_numero_scene + 1
      }
      this.lefts2scenes[i] = current_numero_scene
    }
  },

  // Méthode qui va construire une liste ou chaque élément correspond
  // à une scène et sa valeur est le décalage left. C'est une table
  // qui doit donner très rapidement le numéro de la scène en fonction
  // du décalage left
  left2scene:function(theleft){
    return this.lefts2scenes[theleft];
  },

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
    this.display( numero );
  },
  display: function( numscene ){
    if(this.cur_div_scene_v){
      this.cur_div_scene_v.removeClass('exergue');
      delete this.cur_div_scene_v ;
      this.cur_div_scene_h.removeClass('exergue');
      delete this.cur_div_scene_h ;
    }
    this.TIMELINE_V.scrollTop(Scenes.scenes[numscene].top) ;
    this.cur_div_scene_v = $('div.timeline-v div#scv-'+numscene) ;
    this.cur_div_scene_v.addClass('exergue') ;
    this.cur_div_scene_h = $('div.timeline-h div#sch-'+numscene) ;
    this.cur_div_scene_h.addClass('exergue') ;
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
    this.TIMELINE_SCENES.hide();
  },
  open_timeline:function(){
    this.TIMELINE_SCENES.show();
  },

})

$(document).ready(function(){

  // Initialisation de l'objet qui gère la timeline
  Scenes.init();

  $('div#timeline_scenes').draggable();

  // // Pour le voir directement (implémentation)
  $('div#timeline_scenes').show();
  // $('div#pfa').show();


  $('div#pfa').bind('mousemove',function(ev,ui){
    if(Scenes.inited){
      var x = parseInt(ev.clientX - Scenes.PFA_OFFSET_LEFT) ;
      var scene_num = Scenes.left2scene(x) ;
      // $('div#pfa-developpement').html("x:" + x + " / " + Scenes.l2s( x ) + " / Scène " + scene_num );
      // On scrolle pour afficher la scène dans la timeline
      // verticale.
      Scenes.display(scene_num) ;
    }
  })
  // Déclenchement du suivi du mousemouve
  // Il faut calculer les valeurs pour savoir quoi
  // montrer
  $('div#pfa').bind('mouseover',function(){
  })
  // Fin du suivi du mousemove
  $('div#pfa').bind('mouseout', function(){
  })
})
