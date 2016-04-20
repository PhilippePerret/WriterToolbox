if( undefined == window.Timeline ){ window.Timeline = {} }

$.extend( window.Timeline, {

  // Sera mis à true quand la timeline sera construite
  timeline_built: false,

  show_scenes:function( scenes_ids ){
    F.clean();
    F.show("Pour le moment, la visualisation des scènes n'est pas encore possible.")
    this.show();
  },


  show:function(){
    if( this.timeline_built == false ){ this.build() }
  },

  hide:function(){

  },

  build:function(){
    if($('div#timeline').length){ return }
    this.calcule_window_width() ;
    this.calcule_coef_duree2pixels() ;

    var style = "opacity:width:"+this.window_width+'px;position:fixed;left:40px;top:50px;height:28px;background-color:black;';
    var tm = '<div id="timeline" style="'+style+'"></div>' ;
    $('body').append( tm ) ;

    this.timeline_built = true ;
  },

  calcule_coef_duree2pixels:function(){
    // 2000 px
    // 90 minutes - 5600 secondes
    // duree * coefficient = pixels
    // coefficiant = pixels / duree
    // coefficient = 2000 / 5600 secondes
    this.s2p = this.window_width / Film.duree ;
  },

  calcule_window_width:function(){
    this.window_width = $(window).width() - 80 ;
  }

})
