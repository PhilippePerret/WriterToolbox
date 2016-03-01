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
  },

  //
  set_modified:function(modified){
    if(undefined == modified){ modified = true }
    $('a#btn_apply')[modified ? 'show' : 'hide']() ;
  },

  save_films_options:function(){
    var data = JSON.stringify(this.modifications) ;
    console.log(data)
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
  }

})
