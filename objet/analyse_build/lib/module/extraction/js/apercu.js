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
  Preview.get_current_data();
  console.log(Preview.data);
  // On prépare l'affichage
  Preview.prepare_affichage();
  // Activation de la bonne feuille de styles
  Preview.applique_feuille_de_style();
  // On affiche le résultat (l'aperçu)
  Preview.show();
}

/**
  * OBJET PREVIEW
  *
  */
window.Preview = {
  data: {
    type:       null,
    from_time:  null,
    to_time:    null,
    avant_numero: '',
    apres_numero: '',
    options: {
      // Toute nouvelle option doit être ajoutée ici
      // Attention : une option ne peut qu'être une case à cocher
      with_numero:  false,
      with_horloge: false,
      with_duree:   false,
      with_lieu:    false,
      with_effet:   false,
      with_decor:   false
    }
  },
  // Active la feuille de style en fonction du type d'extrait
  // choisi.
  applique_feuille_de_style:function(){
    for(var icss in FEUILLES_DE_STYLES){
      var cssname = FEUILLES_DE_STYLES[icss];
      $('link#analyse_thing_'+cssname)[0].disabled = (cssname != this.data.type);
    }
  },
  get_current_data: function(){
    // On récupère les options d'affichage
    for(var opt in this.data.options){
      this.data.options[opt] = $('input#thing_'+opt)[0].checked;;
    }
    // Le type de sortie, évènemencier, brin, etc.
    this.data.type = $('select#thing_type').val();
    // On récupère le temps de début et de fin
    this.data.from_time = $('input#thing_from_time').val().toSeconds();
    this.data.to_time   = $('input#thing_to_time').val().toSeconds();
    // On récupère les autres valeurs
    var l = ['avant_numero', 'apres_numero'];
    for(var i in l){
      prop = l[i];
      this.data[prop] = $('#thing_'+prop).val();
    }
  },

  prepare_affichage:function(){
    // console.log(this.data);
    switch(this.data.type){
      case 'brin':
        return this.prepare_affichage_brin();
        break;
      case 'chemindefer':
      case 'sequencier':
      case 'evenemencier':
        return this.prepare_affichage_type_sequencier();
        break;
    }
  },
  prepare_affichage_brin:function(){
    var template = "" ; // le texte template final
    var apercu   = '' ; // Le texte complet final
    var opts = this.data.options;
    this.apercu = apercu;
  },
  // Retourne le code d'exemple d'affichage pour un extrait de type
  // séquencier (chemin de fer, évènemencier, etc.)
  prepare_affichage_type_sequencier:function(){
    var template = "" ; // le texte template final
    var apercu   = '' ; // Le texte complet final
    var data = this.data ;
    var opts = this.data.options;

    if(opts.with_numero){
      template += '<span class="numero">'+data.avant_numero+'_NUMERO_'+data.apres_numero+'</span>'
    }
    if(opts.with_time || opts.with_horloge){
      template += '<span class="horloge">_TIME_</span>' ;
    }
    if(opts.with_lieu){template += '<span class="lieu">_LIEU_</span>'}
    if(opts.with_effet){template += '<span class="effet">_EFFET_</span>'}
    if(opts.with_decor){
      if(opts.with_lieu || opts.with_effet){template += ' — <span class="decor">_DECOR_</span>'}
      else{template += '<span class="decor">_DECOR_</span>'}
    }
    template += '<span class="resume">_RESUME_</span>';
    if(opts.with_duree){template += '<span class="duree horloge">_DUREE_</span>'}

    var liste_props = ['numero', 'resume', 'lieu', 'effet', 'decor', 'time', 'duree'];
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
