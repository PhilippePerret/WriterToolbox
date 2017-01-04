/**
  * @class DataField
  * @description  Tout ce qui concerne les champs de données pour
  *               les analyses TM.
  * @author       Philippe PERRET
  * @version      1.0
  *
  */
if(undefined==window.DataField){window.DataField={}}
$.extend(window.DataField,{

  // Objet courant (Persos, Brins, etc.) -- N0003
  currentObjet:null,

  /** Si la fenêtre de données de l'objet +Objet+ est affichée, on crée
    * une nouvelle donnée, sinon on affiche la liste des items de cet
    * objet.
    */
  show_or_new:function(obj){
    if(console){console.log('-> DataField.show_or_new('+obj.name+')')}
    if(obj == this.currentObjet){
      this.redefine_data(obj);
      this.create_new_item(obj);
    }else{
      Collector.textarea.focus();//N0006
      if(this.currentObjet){this.hide(this.currentObjet)}
      this.show(obj)
    }
    if(console){console.log('<- DataField.show_or_new('+obj.name+')')}
  },
  /** AFFICHER L'OBJET +objet+
    * “Afficher” signifie : soit afficher la liste si elle est prête,
    * soit afficher le champ pour définir les données si les données n'existent
    * pas encore.
    */
  show:function(obj){
    if(console){console.log('-> DataField.show('+obj.name+')')}
    if(this.get_items(obj,{quiet:true})){this.show_liste_items(obj)}
    else{this.redefine_data(obj)}
    if(this.currentObjet){this.hide(this.currentObjet)}
    this.currentObjet = obj ;
    if(console){console.log('<- DataField.show('+obj.name+')')}
  },

  /** CACHER L'OBJET +objet+
    * Masque tous les éléments de l'objet +objet+, à commencer par le
    * champ d'édition et le listing.
    */
  hide:function(obj){
    if(console){console.log('-> DataField.hide('+obj.name+')')}
    obj.champ_data.hide();
    if(obj.panneau&&obj.panneau.length)obj.panneau.hide();
    if(console){console.log('<- DataField.hide('+obj.name+')')}
  },

  /** RÉCUPÉRATION DES DONNÉES DANS LE CHAMP
    *
    * Méthode qui récupère les items de type +Objet+ pour pouvoir insérer des
    * balises.
    *
    * @retourne TRUE si les items ont pu être récupérés, sinon FALSE
    * @produit  La définition de la propriété +items+ de l'objet
    *
    * Ces données sont les mêmes que celles définies pour le fichier des
    * personnages dans la collecte. C'est-à-dire avec une donnée personnage
    * qui commence par "PERSONNAGE:<identifiant>"
    *
    * +options+
    *   quiet     Si true, pas de message en cas d'absence de données
    */
  get_items:function(Objet, options){
    if(console){console.log('-> DataField.get_items('+Objet.name+')')}
    var its = Objet ;
    if(undefined==options){options={}}
    its.panneau = null;
    its.items = null;
    var data_str_items = its.champ_data.val().trim();
    try{
      if(data_str_items == ''){throw('Il faut définir les '+its.strings.pluriel+'.')}
      data_str_items = data_str_items.split("\n");
      var lesItems  = [];
      var i_item    = -1
      // On boucle sur toutes les données
      for(var i=0, len=data_str_items.length;i<len;++i){
        var line = data_str_items[i];
        if(line.trim() == '' || line.substring(0,1)=='#'){continue}
        var dline = line.split(':');
        var prop = dline[0].trim().toLowerCase();
        var valu = dline[1].trim();
        if(valu == ''){valu = null}
        if(prop == its.type){
          // Un nouvel item
          var new_item = $.extend({}, its.default_data);
          $.extend(new_item, {key: valu, index: ++i_item});
          lesItems.push(new_item);
        }else{
          // Une propriété du personnage courant, sauf s'il n'y en a pas
          if(i_item < 0){throw('Les données '+its.strings.pluriel+' sont mal définies.')}
          lesItems[i_item][prop] = valu ;
        }
      }
      its.items = lesItems ;
      if(console){console.log('<- DataField.get_items('+Objet.name+')')}
      return true;
    }catch(erreur){
      if(false == options.quiet){F.error(erreur)}
      if(console){console.log('<- DataField.get_items('+Objet.name+')')}
      return false;
    }
  },

  /**
    * AFFICHAGE DE LA LISTE DES ÉLÉMENTS
    */
  show_liste_items:function(obj, options){
    if(console){console.log('-> DataField.show_liste_items('+obj.name+')')}
    if(this.build_panneau(obj, options)){
      obj.champ_data.hide(); //N0007
      obj.panneau.show();
      obj.champ_data.hide();
    }
    if(console){console.log('<- DataField.show_liste_items('+obj.name+')')}
  },

  // Insert une balise de l'élément courant
  insert_balise_current_objet:function(item_index){
    this.insert_balise(this.currentObjet, item_index)
  },

  /**
    * INSERTION D'UNE BALISE
    *
    * cf. N0001
    */
  last_indexes:{}, timers_last:{},
  insert_balise:function(Objet, item_index){
    var its = Objet;
    if(null == its.items){its.get_items()}
    if(null == its.items)return;
    var litem = its.items[item_index];
    if(!litem){return F.error('Aucun '+its.type+' n’est défini à l’index '+item_index+'.')}
    var balise = "["+its.tag+"#"+litem.key+"]";
    // if(item_index == this.last_perso_index){
    if(item_index == this.last_indexes[its.type]){
      balise += ' ';
      Selection.set(Collector.textarea, balise, {end: true});
    }else{
      Selection.set(Collector.textarea, balise);
      this.last_indexes[its.type] = item_index;
      this.timers_last[its.type] = setTimeout('DataField.reset_last_item("'+its.type+'")', 2000)
    }
  },
  reset_last_item:function(item_type){
    delete this.last_indexes[item_type];
    clearTimeout(this.timers_last[item_type]);
    delete this.timers_last[item_type];
  },


  /**
    * Construction du panneau de l'objet +Objet+
    */
  build_panneau:function(obj, options){
    if(console){console.log('-> DataField.build_panneau('+obj.name+')')}
    var its = obj;
    this.get_items(obj, options);
    if(null == its.items){
      if(console){console.log('<- DataField.build_panneau('+obj.name+') / pas d’éléments')}
      return false
    }
    // Construction de toutes les lignes de l'élément
    var lines = '';
    for(var ip in its.items){ lines += its.line_item_in_list(ip) }
    // Finalisation du panneau
    lines = '<ul class="liste_items">'+lines+'</ul>';
    lien_redefine_data = '<div class="right tiny" onclick="$.proxy(DataField,\'redefine_data\','+its.name+')()">Redéfinir les '+its.strings.pluriel+'</div>';
    lines =  lines + lien_redefine_data ;
    var panneau = '<div id="panneau_'+its.type+'" class="panneau_items">' + lines + '</div>';
    $('body').append(panneau);
    its.panneau = $('div#panneau_'+its.type);
    if(console){console.log('<- DataField.build_panneau('+obj.name+')')}
    return true;
  },

  // Retourne la marque pour le raccourci-clavier d'une liste d'éléments
  mark_shortcut_for:function(ip){
    var mark = '';
    if(ip < 10){mark += "CTRL " + ip + ' PN'}
    else if(ip == 10){mark += 'CTRL MAJ @'}
    else if (ip < 16){mark += 'CTRL MAJ ' + (ip - 10)}
    if(mark != ''){mark += ' : '}
    return mark;
  },

  /** Pour créer un nouvel objet du type Objet
    *
    */
  create_new_item:function(obj){
    if(console){console.log('-> create_new_item('+obj.name+')')}
    var dnewitem  = obj.data_new_item();
    var code      = dnewitem.code;
    delete dnewitem.code;
    Selection.set(obj.champ_data, code, dnewitem);
    if(console){console.log('<- create_new_item('+obj.name+')')}
  },

  /** Pour redéfinir les données de l'objet Objet. Elle supprime le panneau
    * des éléments et affiche le champ de data.
    */
  redefine_data:function(obj){
    if(console){console.log('-> redefine_data')}
    var its = obj;
    if(its.panneau){its.panneau.remove()}
    its.panneau = null;
    its.items   = null;
    its.champ_data.show().focus();
    if(console){console.log('<- redefine_data')}
  },

  /** Capteur d'évènement keypress lorsque l'on se trouve dans
    * le champ des data des personnages
    */
  onkeypress:function(ev){

    // N0005
    if(false == window.common_key_press_shortcuts(ev)){return false}

    if(ev.keyCode > 0){
      switch(ev.keyCode){
        case 9:
          /** TABULATION
            * Passage à la donnée suivante ou précédente
            */
          DataField.select_other_property(this.currentObjet.champ_data, {shiftKey: ev.shiftKey})
          break;
        default:
          return true;
      }
      return stop_event(ev);
    }

  },

  /**
    * Pour sélectionner une autre propriété (en sachant qu'une ligne
    * de propriété est toujours construite de la même façon :
    *     PROPERTY: VALUE)
    *
    * +options+
    *     shiftKey      True si la touche majuscule a été pressée. Dans ce
    *                   cas on va à la propriété précédente.
    */
  select_other_property:function(field, options){
    if(undefined==options){options=this.default_options_select_property}
    if(options.shiftKey){DataField.select_previous_property(field)}
    else{DataField.select_next_property(field)}
  },
  /**
    * Pour sélectionner la propriété précédente dans le champ
    * de données des personnages.
    */
  select_previous_property:function(field){
    var dec = Selection.of(field).end;
    var code = field.val().substring(0, dec - 1);
    var int = code.lastIndexOf(': ', dec);
    if(int < 0){return false}else{int += 2}
    var out = code.indexOf("\n", int);
    if(out < 0){out = code.length}
    Selection.select(field, {start: int, end: out});
  },
  select_next_property:function(field){
    var dec = Selection.of(field).end;
    var code = field.val();
    var int = code.indexOf(': ', dec);
    if(int < 0){return false}else{int += 2}
    var out = code.indexOf("\n", int);
    if(out < 0){out = code.length}
    Selection.select(field, {start: int, end: out});
  },


  build_data_field:function(Objet){
    var its = Objet;
    var field = '<textarea' +
      ' id="'+its.type+'s'+'"'+
      ' class="data_field"'+
      ' placeholder="Données des '+its.strings.pluriel+'"'+
      ' style="display:none;"'+
      '>';
    $('body').append(field);
  },


  // Options par défaut de la méthode `select_other_property`
  default_options_select_property:{
    shiftKey: false
  },

  initialize:function(Objet){
    var its = Objet;
    if('function' == typeof its.initialize){its.initialize()}
    this.build_data_field(Objet);
    its.champ_data = $('textarea#'+its.type+'s');// p.e. 'personnages'

    // Observers
    its.champ_data.bind('focus',function(){
      window.onkeypress = $.proxy(Objet,'onkeypress');
    })
    its.champ_data.bind('blur', function(){
      window.onkeypress = window_on_key_press;
      $.proxy(DataField,'show_liste_items', Objet, {quiet:true})();
    })

  }

})
