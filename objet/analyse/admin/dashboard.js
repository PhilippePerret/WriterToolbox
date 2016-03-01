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


  change_bit:function(fid, ibit){
    var ifilm = new Film( fid ) ;
    var opts = ifilm.options.split('') ;
    var opts_init = "" + ifilm.options ;
    var devient_actif = opts[ibit] == "0" ;
    opts[ibit] = devient_actif ? "1" : "0" ;
    opts = opts.join('') ;
    ifilm.set_options( opts ) ;
    var btn_name  = devient_actif ? "OUI" : "NON" ;
    var btn_id    = "btn_f"+fid+"-b"+ibit ;
    var btn       = $('a#'+btn_id) ;
    btn.text(btn_name);
  },

  // Marque un film analysé ou non analysé
  // On le met à la valeur de `bit_analyzed`
  set_analyzed:function( fid ){
    var f = new Film( fid ) ;
    f.toggleAnalyzed() ;
    this.current_film = f ;
    this.poursuivre_set_analyzed({ok: true})
  },
  poursuivre_set_analyzed:function(rajax){
    if(rajax.ok){
      // Message d'annonce final
      F.show(
        "Le film a été marqué " + (this.current_film.is_analyzed() ? "analysé" : "non analysé") + "."
      );
    }
  }

})
