if(undefined==window.Analyse){window.Analyse = {}}

var Film = function(fid){
  this.id = fid ;

  // Le div principal contenant tout le film
  this.div = $("div#film-"+ this.id) ;

  // La valeur actuelle des options
  this.options = this.div.attr('data-options') ;

  // Le bouton pour régler le bit1, le fait que le
  // film est analysé ou non.
  this.btn_set_analyzed = $("a#btn_bit1-"+this.id) ;
}
Film.prototype.option = function(iopt){
  return this.options.substr(iopt - 1, 1)
}
Film.prototype.set_options = function(opts){
  this.options = opts ;
  this.div.attr( 'data-options', opts ) ;
}

// ---------------------------------------------------------------------

$.extend(window.Analyse, {

  modifications: {},

  change_bit:function(fid, ibit){
    var ifilm = new Film( fid ) ;
    var opts = ifilm.options.split('') ;
    var opts_init = "" + ifilm.options ;
    var devient_actif = opts[ibit] == "0" ;
    opts[ibit] = devient_actif ? "1" : "0" ;
    opts = opts.join('') ;
    ifilm.set_options( opts ) ;

    // On mémorise la nouvelle valeur des options et on
    // indique que les valeurs ont été modifiées
    this.modifications[fid] = opts ;
    this.set_modified() ;

    var btn_name  = devient_actif ? "OUI" : "NON" ;
    var btn_id    = "btn_f"+fid+"-b"+ibit ;
    var btn       = $('a#'+btn_id) ;
    btn.text(btn_name);
    if(devient_actif){ btn.removeClass('bgred').addClass('bgblue') }
    else { btn.removeClass('bgblue').addClass('bgred') }
  },

  //
  set_modified:function(modified){
    if(undefined == modified){ modified = true }
    $('a#btn_apply')[modified ? 'show' : 'hide']() ;
  },

  save_films_options:function(){
    var data = JSON.stringify(this.modifications) ;
    var data_ajax = {
      url: "admin/save_options?in=analyse",
      film_options: data,
      message_on_operation: "Enregistrement des options en cours…",
      onreturn: $.proxy(Analyse,'retour_save_film_options')
    }
    Ajax.send(data_ajax)
  },
  retour_save_film_options:function(rajax){
    if (rajax.ok){
      this.set_modified( false ) ;
      this.modifications = {} ;
    }
  },


  /** ---------------------------------------------------------------------
    *   Méthodes de filtrage
    *
    * Méthodes réagissant aux cases à cocher de l'interface
    * --------------------------------------------------------------------- */

  TABLE_CBS: {
    'analyzed': {bit: 0, reg: "1"},
    'tm':       {bit: 3, reg: "(1|3)"}
  },
  TABLE_BITS_OPTIONS: {
    0: 'analyzed',
    1: null,
    2: null,
    3: 'tm'
  },
  // Méthode principale
  filtre_liste_films:function(){

    var hash = new Object() ;
    $(['tm', 'analyzed']).each(function(i, sym){
      hash[sym] = $('input[type="checkbox"]#cb_only_' + sym)[0].checked ;
    })

    // On construit l'expression régulière qui va permettre de
    // filtrer les films voulus.
    var reg_options_req = "";
    var sym, reg ;
    for(var index_bit in this.TABLE_BITS_OPTIONS){
      sym = this.TABLE_BITS_OPTIONS[index_bit] ;
      if (sym != null){
        reg_options_req += hash[sym] == true ? this.TABLE_CBS[sym].reg : '.' ;
      } else {
        reg_options_req += '.'
      }
    }

    reg_options_req = new RegExp("^" + reg_options_req)

    var o, opts, concerned ;
    $('div#films > div.film').each(function(){
      o = $(this) ;
      opts = o.attr('data-options') ;
      concerned = opts.match(reg_options_req) != null ;
      if(concerned){o.show()}else{o.hide()}
    })
  },

  // Décoche tout
  filtre_none:function(){
    $('div#films > li.film').each(function(){$(this).show()})
  }

})
