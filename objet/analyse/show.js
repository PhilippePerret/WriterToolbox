if(undefined==window.Scenes){window.Scenes={}}
if(undefined==window.PFA){window.PFA={}}

// Raccourci pour utiliser seulement `s(num scène)` dans les
// attributs onclick
function s(numeros){Scenes.show(numeros)}
function sv(numero){Scenes.show_in_timelinev(numero)}


/* ---------------------------------------------------------------------
    Les méthodes Scenes (Timeline) de contrôleur
   --------------------------------------------------------------------- */
$.extend(window.Scenes, {

  // Pour l'affichage d'une scène dans le scénier
  // +numero+ peut être :
  //  - {Number} un numéro seul
  //  - {Object} une liste Array de numéros de scènes
  //  - {String} un string avec les numéros séparés par des espaces
  /** Affichage de la timeline des scènes
    *
    * Si +numeros+ est strictement identique au précédent
    * numéros envoyés, c'est une fermeture qui est demandée
    *
    */
  last_numeros: null,
  show:function(numeros){

    // Numéros identiques à la demande précédente
    // => Fermeture de la timeline demandée
    // Sinon, on mémorise ces numéros pour savoir si c'est
    // une fermeture qui sera demandée.
    if(numeros == this.last_numeros){
      this.reset();
      this.close_timeline();
      this.last_numeros = null ;
      return ;
    } else { this.last_numeros = numeros }
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
    // On se rend toujours à la première scène pour la mettre
    // en exergue.
    if( numeros[0] ){ this.display( numeros[0] ) }

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
  }

})
/* ---------------------------------------------------------------------
    Les méthodes PFA de contrôleur
   ---------------------------------------------------------------------*/
$.extend(window.PFA, {

  // Pour le bouton qui affiche et masque le paradigme
  // de Field et les boutons de navigation dans les noeuds
  toggle:function(){
    if(this.displayed){ this.hide() } else { this.init(); this.show() }
    this.displayed = !this.displayed ;
  },

  /** Pour sélectionner le nœud précédent ou le nœud suivant
    *
    * Toutes les scènes candidates sont recherchées et mémorisées
    * dès qu'on clique sur le bouton "P.F.A.". La valeur
    * this.icandidate permet ensuite de naviguer de scène en
    * scène.
    */
  prev_node: function(){
    if( this.icandidate === null || this.icandidate == 0 ){
      this.icandidate = this.nodes_candidates.length
    }
    this.icandidate -= 1 ;
    this.display_node_candidate();
  },
  next_node: function(){
    if(this.icandidate === null || this.icandidate == this.nodes_candidates.length - 1){
      this.icandidate = -1
    }
    this.icandidate += 1 ;
    this.display_node_candidate();
  },

  // Affiche la scène candidate voulue
  display_node_candidate:function(){
    var candidate = this.nodes_candidates[this.icandidate] ;
    this.show_scene_et_node( candidate.scene_num, candidate.inode ) ;
  }

})
/* ---------------------------------------------------------------------
    Les méthods Scenes fonctionnelles
   --------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
    Les méthodes PFA fonctionnelles
   ---------------------------------------------------------------------*/
$.extend(window.PFA, {
  CALQUE: null, // réglé par l'init de Scenes
  CADRE: null,
  displayed: false,


  // Initialisation du PFA
  //
  pfa_inited: false,
  init:function(){
    if(this.pfa_inited)return;
    this.find_nodes_candidates();
    this.pfa_inited = true ;
  },

  zonew: 5, //4.16, //8.33,
  DATA_NODE: [
    { hname: 'Pivot 1',      pos: 25 },
    { hname: '1/3',          pos: 33 },
    { hname: 'Clé de voûte', pos: 50 },
    { hname: '2/3',          pos: 66 },
    { hname: 'Pivot 2',      pos: 75 }
  ],

  /**
    * Méthode fonctionnelle qui cherche les scènes
    * candidate par noeud. Cela produit une liste
    * (nodes_candidates) dont chaque élément est un
    * hash contenant le numéro de la scène, l'indice
    * du noeud et la hauteur de la scène dans la
    * timeline V pour un affichage plus rapide.
    *
    */
  find_nodes_candidates: function(){
    this.nodes_candidates = []
    var inode,
        dnode,
        node_debut, node_fin,
        scene_num = 0 ;
    // On boucle sur chaque node pour récupérer les scènes
    // candidate.
    // Un "node", c'est par exemple un pivot ou la clé de voûte
    // Une "scène candidate", c'est une scène qui pourrait se
    // trouver à l'endroit voulu.
    for(inode = 0, len = this.DATA_NODE.length; inode < len; ++inode){
      dnode     = this.DATA_NODE[inode] ;
      node_debut = dnode.pos - PFA.zonew ;
      node_debut = parseInt((node_debut/100) * Scenes.DUREE_FILM) ;
      node_fin   = dnode.pos + PFA.zonew ;
      node_fin   = parseInt((node_fin/100)   * Scenes.DUREE_FILM)

      // On récupère toutes les scènes candidates pour ce noeud
      // Une scène est candidate lorsque son temps de fin est
      // supérieur strictement au temps de début du noeud ou
      // que son temps de début est inférieur strictement au
      // temps de fin
      do {
        scene_num += 1 ;
        scene_debut   = Scenes.scenes[scene_num].time ;
        scene_fin     = Scenes.scenes[scene_num + 1].time - 1 ;
        is_candidate  = scene_fin > node_debut && scene_debut < node_fin ;
        if(is_candidate){
          this.nodes_candidates.push({
            scene_num: scene_num, inode: inode
          })
        }
      } while( is_candidate || scene_fin < node_debut )
    } // Fin de boucle sur chaque node
  },

  show:function(){
    $('a#tls_toggle_pfa').addClass('actived') ;
    $('div#tls_pfa_tools_nav').css('visibility', 'visible');
    this.CALQUE.show();
    // Quand on demande l'affichage du PFA, il faut effacer
    // toute marque qui aurait été faite sur la timeline H
    Scenes.reset();
  },
  hide:function(){
    $('a#tls_toggle_pfa').removeClass('actived') ;
    $('div#tls_pfa_tools_nav').css('visibility', 'hidden');
    this.CALQUE.hide();
  },

  /* ---------------------------------------------------------------------
    Section gérant la "détection" des scènes clés du paradigme de
    Field augmenté. C'est un outil de la Timeline des scènes qui
    permet de passer en revue les scènes proches des temps des noeuds
    important pour trouver celle qui pourrait avoir fonction de ce
    noeud.
  ---------------------------------------------------------------------*/
  // Liste des scènes "candidates" au noeud passé en revue
  // On la mémorise pour pouvoir repasser par elle avec la flèche
  // gauche
  nodes_candidates: [],

  // L'index dans nodes_candidates
  icandidate: null,


  show_scene_et_node: function(scene_num, inode){
    Scenes.display( scene_num ) ;
    $('span#tls_pfa_nav_libelle').html(this.DATA_NODE[inode].hname + " ?")
  }

})



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
    this.TIMELINE_H         = $('div#timeline_scenes div.timeline-h') ;
    this.TIMELINE_V         = $('div#timeline_scenes div.timeline-v') ;
    this.CALQUE_PFA = PFA.CALQUE = $('div#pfa') ;

    // On les affiche pour prendre leurs dimensions
    this.TIMELINE_SCENES.show();
    this.CALQUE_PFA.show();

    // On fait les calculs
    this.PFA_WIDTH            = this.CALQUE_PFA.width();
    this.PFA_OFFSET_LEFT      = this.CALQUE_PFA.offset().left ;
    this.TIMELINE_OFFSET_LEFT = this.TIMELINE_H.offset().left ;

    // On prépare la liste des scènes (Scenes.scenes)
    this.prepare_map_scenes();

    // Initialisation du paradigme de Field (ne sert à
    // rien pour le moment)
    // PFA.init();

    this.DUREE_FILM = parseInt(this.TIMELINE_SCENES.attr('data-film-duree'));
    this.COEF_PIXELS_TO_SECONDS = this.DUREE_FILM / this.TIMELINE_SCENES.find("div#pfa").width();

    // Préparation de la table left->numéro scène
    this.calcule_lefts2scenes();

    this.TIMELINE_SCENES.hide();
    this.CALQUE_PFA.hide();

    this.inited = true ;
  },

  /* ---------------------------------------------------------------------
      Méthodes fonctionnelles
     ---------------------------------------------------------------------*/

  /** Méthodes qui prépare la table des scènes avec pour
    * chaque scène le temps et le décalage de la scène dans
    * la liste verticale, pour pouvoir scroller rapidement
    * à la scène voulue.
    */
  prepare_map_scenes:function(){
    var my = this ;
    my.scenes = {};
    my.TIMELINE_SCENES.find('div.timeline-h div.sc').each(function(){
      var o = $(this);
      var sid = parseInt(o.attr('id').split('-')[1]) ;
      var stime = parseInt(o.attr('data-time')) ;
      var stop  = $('div.timeline-v div#scv-' + sid )[0].offsetTop ;
      // Noter qu'on décale déjà de 40 pixels pour avoir le
      // vrai scrollTop qu'il faudra utiliser
      my.scenes[sid] = { time: stime, top: stop - 40} ;
    })
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
    this.display(numero);
    var i, e ;
    for(i = numero-10; i<numero+10; ++i){
      e = $('div#timeline_scenes div.timeline-v div#scv-'+i) ;
      e.css('opacity', i == numero ? '1' : '0.7')
    }
  },

  display: function( numscene ){
    if(this.cur_div_scene_v){
      this.cur_div_scene_v.removeClass('exergue');
      delete this.cur_div_scene_v ;
      this.cur_div_scene_h.removeClass('exergue');
      this.cur_div_scene_h.css({
        'background-color': this.cur_div_scene_h.attr('data-bgcolor'),
        'top':'0', 'height':'32px', 'opacity':'0.5'
      });
      delete this.cur_div_scene_h ;
    }
    this.TIMELINE_V.scrollTop(Scenes.scenes[numscene].top) ;
    this.cur_div_scene_v = $('div.timeline-v div#scv-'+numscene) ;
    this.cur_div_scene_v.addClass('exergue') ;
    this.cur_div_scene_h = $('div.timeline-h div#sch-'+numscene) ;
    this.cur_div_scene_h.addClass('exergue') ;
    this.cur_div_scene_h.attr('data-bgcolor', this.cur_div_scene_h.css('background-color'));
    this.cur_div_scene_h.css({
      'background-color':'blue',
      'height': '42px',
      'top':'-6px',
      'opacity':'1'
    });
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

  // Pour voir le calque du PFA directement au chargement
  // de la page (pendant l'implémentation)
  // $('div#timeline_scenes').show();
  // $('div#pfa').show();

  Scenes.TIMELINE_H.bind('mousemove',function(ev,ui){
    if(Scenes.inited){
      var x = parseInt(ev.clientX - Scenes.TIMELINE_OFFSET_LEFT) ;
      var scene_num = Scenes.left2scene(x) ;
      // $('div#pfa-developpement').html("x:" + x + " / " + Scenes.l2s( x ) + " / Scène " + scene_num );
      // On scrolle pour afficher la scène dans la timeline
      // verticale.
      Scenes.display(scene_num) ;
    }
  })
})
