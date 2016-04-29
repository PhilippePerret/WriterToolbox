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

  // TODO: Étudier le cas du bit 3 (valeurs 1,2 ou 3)
  change_bit:function(fid, ibit){
    var btn_name, devient_actif ;
    var ifilm = new Film( fid ) ;
    var opts = ifilm.options.split('') ;
    var opts_init = "" + ifilm.options ;
    if( ibit != 3 ){
      devient_actif = opts[ibit] == "0" ;
      opts[ibit] = devient_actif ? "1" : "0" ;
      btn_name  = devient_actif ? "OUI" : "NON" ;
    } else {
      // Cas spécial du bit 3 qui peut avoir la valeur 1, 2 ou 3
      // contrairement aux autres bits qui sont de simples
      // bascules.
      next_val = parseInt(opts[ibit]) + 1 ;
      if(next_val > 3){ next_val = 0 }
      opts[ibit] = next_val.toString();
      devient_actif = next_val > 0 ;
      btn_name = ["???", "TM", "MYE", "MIX"][next_val] ;
    }
    opts = opts.join('') ;
    ifilm.set_options( opts ) ;

    // On mémorise la nouvelle valeur des options et on
    // indique que les valeurs ont été modifiées
    this.modifications[fid] = opts ;
    this.set_modified() ;

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
    'tm':       {bit: 3, reg: "(1|3)"},
    'mye':      {bit: 3, reg: "(2|3)"},
    'lisible':  {bit: 4, reg: "1"},
    'encours':  {bit: 5, reg: "1"},
    'lecture':  {bit: 6, reg: "1"},
    'finie':    {bit: 7, reg: "1"},
    'small':    {bit: 8, reg: "1"}
  },
  TABLE_BITS_OPTIONS: {
    0: 'analyzed',
    1: null,
    2: null,
    3: ['tm', 'mye'],
    4: 'lisible',
    5: 'encours',
    6: 'lecture',
    7: 'finie',
    8: 'small'
  },
  // Méthode principale
  filtre_liste_films:function(){

    var hash = new Object() ;
    for(var sym in this.TABLE_CBS){
      hash[sym] = $('input[type="checkbox"]#cb_' + sym)[0].checked ;
    }
    // $(['tm', 'mye', 'analyzed']).each(function(i, sym){
    //   hash[sym] = $('input[type="checkbox"]#cb_only_' + sym)[0].checked ;
    // })

    // On construit l'expression régulière qui va permettre de
    // filtrer les films voulus.
    var reg_options_req = "";
    var sym, reg ;
    for(var index_bit in this.TABLE_BITS_OPTIONS){
      sym = this.TABLE_BITS_OPTIONS[index_bit] ;
      if(index_bit != 3){
        reg = hash[sym] == true ? this.TABLE_CBS[sym].reg : '.' ;
      }else{
        // Cas spécial du bit 3 (type analyse) qui peut prendre
        // les valeurs 1, 2 ou 3
        val = 0
        if( hash['tm'] ) val += 1 ;
        if (hash['mye']) val += 2 ;
        reg = val == 0 ? '.' : (val == 3 ? "3" : "(3|"+val+")")
      }
      if (sym != null){
        reg_options_req += reg
      } else {
        reg_options_req += '.'
      }
    }

    // console.log("reg_options_req : " + reg_options_req)
    reg_options_req = new RegExp("^" + reg_options_req)

    var o, opts, concerned ;
    var nombre_showed = 0 ;
    $('div#films > div.film').each(function(){
      o = $(this) ;
      opts = o.attr('data-options') ;
      concerned = opts.match(reg_options_req) != null ;
      if(concerned){++nombre_showed;o.show()}else{o.hide()}
    })

    // Afficher le résultat
    var o = $('span#resultat_filtre')
    if (nombre_showed == 0){
      o.html("Aucun film ne correspond aux critères.")
      o.addClass('warning')
    } else {
      o.removeClass('warning');
      o.html(nombre_showed + " films correspondent aux critères.")
    }
  },


  /** Méthode appelée quand on coche la case "Bloquer la
    * liste" pour ne pas avoir une fenêtre qui bouge.
    */
  bloquer_liste:function(bloquer){
    if(undefined == bloquer){bloquer = $('input#cb_bloque_liste')[0].checked}
    UI.bloquer_la_page(bloquer);
  }

})

$(document).ready(function(){
  Analyse.filtre_liste_films();
  Analyse.bloquer_liste();
})
