if(undefined==window.Chrono){window.Chrono={}}
$.extend(window.Chrono,{

  // Le temps de départ du film
  film_start_time: null,
  // Le temps réel au lancement du film
  real_start_time: null,

  /**
    * Méthode principale qui retourne le temps courant relatif commem une
    * horloge
    *
    * Note : ce temps dépend du start_time défini dans le champ.
    */
  current_time_as_horloge:function(){
    if(!this.film_start_time){this.get_start_time()}
    var ct = this.current_time();
    // On transforme en horloge
    var hrs = Math.floor(ct / 3600) ;
    var mns = ct % 3600 ;
    var scs = mns % 60  ;
    if(scs < 10){scs = '0' + scs}
    var mns = Math.floor(mns / 60) ;
    if(mns < 10){mns = '0' + mns}
    return '' + hrs + ':' + mns + ':' + scs ;
  },

  /**
    * Méthode qui retourne le temps courant relatif en secondes
    *
    */
  current_time:function(){
    // On commence par calculer la différence entre le temps courant et
    // le temps au lancement du chronomètre
    var diff = (new Date()).getTime() - this.real_start_time ;
    // On ajoute ensuite cette différence au temps de démarrage de la
    // collecte
    return parseInt((this.film_start_time + diff)/1000) ;
  },

  /**
    * Méthode qui récupère le temps de départ
    * S'il est bien défini, on renvoie TRUE, sinon, on signale
    * l'erreur et on renvoie FALSE.
    */
  get_start_time:function(){
    F.clean();
    var time = $('input#start_time').val().trim();
    try{
      if(time == ''){time = '0:00:05'}
      time = time.split(':').reverse();
      if(time.length != 3){throw('Il faut impérativement donner une horloge avec les heures.')}
      time = parseInt(time[0],10) + parseInt(time[1]||0,10) * 60 + parseInt(time[2]||0,10) * 3600;
      this.film_start_time = time * 1000 ;
      this.real_start_time = parseInt((new Date()).getTime()) ;
      return true ;
    }catch(erreur){
      return F.error(erreur);
    }
  },

  /** ---------------------------------------------------------------------
    *   Toutes les méthodes concernant l'horloge
    --------------------------------------------------------------------- */
  start_horloge:function(){
    this.timer_horloge = setInterval('Chrono.display_time()', 500)
  },
  stop_horloge:function(){
    clearInterval(this.timer_horloge);
    delete this.timer_horloge;
  },
  display_time:function(){
    $('span#horloge').html(this.current_time_as_horloge());
  }
})
