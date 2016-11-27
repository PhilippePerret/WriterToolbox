/**
  * Toutes les méthodes pour gérer l'aperçu de l'extraction
  *
  */

// Prototype qui transforme le string d'une horloge (x:xx:xx) en
// nombre de secondes.
// Le string peut avoir la valeur exceptionnelle 'FIN' qui renverra
// la fin du film en secondes.
String.prototype.toSeconds = function(){
  str = this.toString();
  if (str == 'FIN'){
    return FILM_DUREE_SECONDES;
  }else{
    var l = str.split(':').reverse() ;
    return parseInt(l[0]) + parseInt(l[1]||0) * 60 + parseInt(l[2]||0) * 3600
  }
}

Number.prototype.toHorloge = function(){
  secondes = this;
  reste = secondes % 3600 ;
  heures = (secondes - reste) / 3600 ;
  seconds = reste % 60 ;
  minutes = (reste - seconds) / 60;
  minutes > 9 || (minutes = "0"+minutes);
  seconds > 9 || (seconds = "0"+seconds);
  return heures + ":" + minutes + ":" + seconds ;
}

/**
  * Méthode principale appelée pour actualiser l'aperçu de l'affichage
  *
  */
function apercu(){
  // On relève les données actuelles
  Preview.get_current_date();
  // console.log(Preview.data);
  // On prépare l'affichage
  Preview.prepare_affichage();
  // On affiche le résultat (l'aperçu)
  Preview.show();
}

/**
  * OBJET PREVIEW
  *
  */
window.Preview = {
  data: {
    from_time:  null,
    to_time:    null,
    options: {
      with_horloge: false,
      with_duree:   false,
      with_lieu:    false,
      with_effet:   false,
      with_decor:   false
    }
  },
  get_current_date: function(){
    // On récupère les options d'affichage
    for(var opt in this.data.options){
      this.data.options[opt] = $('input#thing_'+opt)[0].checked;;
    }
    // On récupère le temps de début et de fin
    this.data.from_time = $('input#thing_from_time').val().toSeconds();
    this.data.to_time   = $('input#thing_to_time').val().toSeconds();
  },

  prepare_affichage:function(){
    var template = "" ; // le texte template final
    var apercu   = '' ; // Le texte complet final
    var opts = this.data.options;
    if(opts.with_time || opts.with_horloge){
      template += '<span class="horloge">_TIME_</span>' ;
    }
    if(opts.with_lieu){template += '<span class="lieu">_LIEU_</span>'}
    if(opts.with_effet){template += '<span class="effet">_EFFET_</span>'}
    if(opts.with_decor){
      if(opts.with_lieu || opts.with_effet){template += ' — <span class="decor">_DECOR_</span>'}
      else{template += '<span class="decor">_DECOR_<span>'}
    }
    template += '_RESUME_';
    if(opts.with_duree){template += '<span class="duree horloge">_DUREE_</span>'}

    var liste_props = ['resume', 'lieu', 'effet', 'decor', 'time', 'duree']
    for(var i in this.DATA_SCENES){
      var data_scene = this.DATA_SCENES[i];
      if(data_scene.time < this.data.from_time)continue;
      if(data_scene.time > this.data.to_time)continue;
      // On met le template dans le texte final de la scène
      var final_scene_text = template;
      for(var iprop in liste_props){
        var prop = liste_props[iprop];
        var key_rep = '_' + prop.toUpperCase() + '_';
        var regexp = new RegExp(key_rep, 'g');
        valremp = data_scene[prop];
        if(prop == 'time' || prop == 'duree'){valremp = valremp.toHorloge()}
        final_scene_text = final_scene_text.replace(regexp, valremp);
      }
      apercu += '<div class="scene">' + final_scene_text + '</div>';
    }

    this.apercu = apercu;
  },

  show:function(){
    console.log("Je vais mettre le div#apercu à " + this.apercu);
    $('div#apercu').html(this.apercu);
  },



  DATA_BRINS : [
    {id: 1, }
  ],
  DATA_SCENES: [
    { time: 0, resume: "Résumé de la première scène", numero: 1, duree: 60,
      data_paragraphes:[], brins: [],
      lieu: 'EXT.', effet: 'JOUR', decor: 'BUREAU'},
    { time: 60, resume: "La deuxième scène à 1 minute", numero: 2, duree: 62,
      data_paragraphes:[], brins:[],
      lieu: 'INT.', effet: 'NUIT', decor: 'CHAMBRE'},
    { time: 122, resume: "La troisième scène à 2 minutes 2", numero: 3, duree: 448,
      data_paragraphes:[], brins:[],
      lieu: 'EXT.', effet: 'NUIT', decor: 'ROUTE'},
    { time: 600, resume: "La quatrième scène à 10 minutes.", numero: 4, duree: 200,
      data_paragraphes:[], brins:[],
      lieu: 'INT.', effet: 'NUIT', decor: 'CHAMBRE'},
  ]

}
