if(undefined==window.Collector){window.Collector={}}
$.extend(window.Collector,{

  /**
    * Le textarea pour recevoir le texte
    */
  textarea: null,

  /**
    * Lancer la collecte
    *
    * Cette méthode est appelée lorsque l'on clique sur le bouton START
    */
  running: false,
  start:function(){
    if(this.running){
      // Pause demandée
      this.champ_start_time.val(Chrono.current_time_as_horloge())
      this.bouton_start.val('START');
      this.running = false;
      Chrono.stop_horloge();
    }else{
      // Démarrage de la collecte
      if(!Chrono.get_start_time()){return}
      Chrono.start_horloge();
      this.textarea.focus();
      this.bouton_start.val('STOP');
      this.running = true;
    }
  },
  /**
    * Pour obtenir l'aide
    * C'est utile lorsque la fenêtre est bloquée. La méthode prend le div
    * de l'aide et l'affiche dans la page.
    */
  aide:function(){
    var aide = $('div#aide');
    if(aide.hasClass('fixed')){
      aide.removeClass('fixed');
      if(Persos.panneau){Persos.panneau.css('z-index',0)}
      // On revient dans le champ de saisie
      this.textarea.focus();
      aide.hide();
    }
    else{
      aide.show();
      aide.addClass('fixed');
      if(Persos.panneau){Persos.panneau.css('z-index',-1)}
    }
  },
  /**
    * Méthode pour créer une nouvelle scène dans le collecteur
    * Si le chronomètre tourne, on indique le temps de la scène
    * Le chronomètre "tourne" lorsque la case "Real time" est
    * cochée et qu'un temps de départ est fourni.
    */
  create_new_scene:function(){
    var le_temps = Chrono.current_time_as_horloge();
    var code = "\n\nSCENE:" + le_temps + "\n\tRESUME: \n\tFONCTION: \n\tSYNOPSIS: ";
    // On met le code dans le champ et on se place après 'RESUME: '
    this.textarea.val(this.textarea.val() + code);
    var offset = this.textarea.val().length ;//- 24;
    Selection.select(this.textarea,{start: offset, end: offset});
  },

  insert_note:function(){
    var letemps   = Chrono.current_time_as_horloge();
    var labalise  = this.get_new_balise_for('NOTE') + ' ';
    Selection.set(this.textarea,labalise);
    var sel = Selection.of(this.textarea);
    Selection.select(this.textarea, {start: sel.end, end: sel.end});
    Selection.set(this.textarea,letemps);
  },

  /** Méthode qui retourne un ID vierge pour l'élément de type
    * +type+ (par exemple 'NOTE'). La méthode list tout le code
    * pour déterminer le dernier indice utilisé et renvoie l'indice
    * suivant.
    */
  get_new_balise_for:function(type){
    var code = this.textarea.val();
    var fin = false;
    var i = 0;
    while(!fin){
      var balise = type + '#' + (++i) + ':';
      if(code.indexOf(balise) < 0){
        return balise ;
      }
    }
  },

  /**
    * Méthode principale qui permet de placer le curseur après un
    * mot particulier du texte
    *
    * +options+
    *     before      Si TRUE, on cherche le mot avant la position
    *                 courante, si FALSE on cherche le mot après la position
    *                 courante
    */
  goto_after_word:function(word, options){
    var before = options.before;
    var code   = this.textarea.val();
    var current_pos = Selection.of(this.textarea).start;
    var dec ;
    if(before){
      // Recherche AVANT la position actuelle
      current_pos -= 1;
      code = code.substring(0, current_pos);
      dec = code.lastIndexOf(word);
    }else{
      // Recherche APRÈS la position actuelle
      dec = code.indexOf(word, current_pos);
    }
    if(dec < 0){return}
    dec += word.length;
    Selection.select(this.textarea,{start: dec, end: dec})
  },

  /**
    * Capteur d'évènement press key quand on est dans le textarea
    * du collecteur
    *
    * Pour le moment, on ne peut que mettre en route le chronomètre
    * qui va permettre de suivre le film sans s'arrêter pour mettre
    * toutes les scènes.
    */
  onkeypress:function(ev){
    if(false == window.common_key_press_shortcuts(ev)){return false}
    if( ev.metaKey && ev.shiftKey){
      // console.log("Je passe ici, oui")
      switch(ev.charCode){
        case 83:
          // CTRL + CMD + S => next scene
          this.goto_after_word('SCENE:', {before: false})
          break;
        default: return;
      }
      return stop_event(ev);
    }else if(

      ev.ctrlKey && ev.shiftKey

    ){
      switch(ev.charCode){
        case 83:
          // CTRL + CMD + S => next scene
          this.goto_after_word('SCENE:', {before: true})
          break;
        default:
          if (ev.charCode > 47 && ev.charCode < 57){
            // L'élément courant de 10 à 19
            $.proxy(DataField,'insert_balise_current_objet', 10 + ev.charCode - 48)()
          }
          // SINON
          return true;
      }
      return stop_event(ev);
    }else if(

      /** ---------------------------------------------------------------------
        *   AVEC LA TOUCHE CONTROL
        --------------------------------------------------------------------- */
      ev.ctrlKey

    ){
      switch(ev.charCode){
        /**
          * CTRL + H crée une horloge au temps courant
          */
        case 104:
          this.insert_horloge();
          break;
        /**
          * CTRL + N crée une note au temps courant
          */
        case 110:
          this.insert_note();
          break;
        /**
          * CTRL + S crée un nouvelle scène
          */
        case 115:
          this.create_new_scene(at_time = true);
          break;
        default:
          if (ev.charCode > 47 && ev.charCode < 57){
            // L'élément courant de 0 à 9 (pour 10 à 19, cf. plus haut)
            var indperso = ev.charCode - 48;
            if(ev.altKey){indperso += 10}
            $.proxy(DataField,'insert_balise_current_objet', indperso)()
          }else{
            return true;
          }
        }
      }else{
        /** ---------------------------------------------------------------------
          *
          *   AVEC AUCUN MODIFIEUR
          *
          --------------------------------------------------------------------- */
        switch(ev.keyCode){
          case 9:
            /** TABULATION
              *
              * Comme pour le champ des données personnage ou autre, la
              * touche tabulation permet de se déplacer de donnée en donnée
              * Avec la touche espace, on remonte de donnée en donnée
              *
              */
              DataField.select_other_property(this.textarea, {shiftKey: ev.shiftKey})

            break;
          default:
            return true;
        }
      return stop_event(ev);
    }
  },

  /**
    * Insert une HORLOGE
    *
    */
  insert_horloge:function(){
    Selection.set(this.textarea, Chrono.current_time_as_horloge() + ' ', {end: true})
  },

  // Initialise le collecteur, notamment en définissant les
  // éléments et les observeurs
  initialize:function(){
    this.textarea         = $('textarea#collector');
    this.bouton_start     = $('input#bouton_start');
    this.champ_start_time = $('input#start_time');

    // Lorsque l'on focus dans le champ de texte, on active les
    // raccourcis clavier
    Collector.textarea.bind('focus',function(){window.onkeypress = $.proxy(Collector,'onkeypress')})
    Collector.textarea.bind('blur',function(){window.onkeypress = window_on_key_press})
  }
})
