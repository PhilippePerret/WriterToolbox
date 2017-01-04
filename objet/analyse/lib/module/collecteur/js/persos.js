if(undefined==window.Persos){window.Persos={}}
$.extend(window.Persos,{

  // Valeurs obligatoires définissant l'élément pour DataField
  // Cf. Le _REFBOOK_ dans ce dossier
  name: 'Persos',
  type: 'personnage', // -- N0004
  tag:  'PERSO',
  strings:{
    pluriel: 'personnages'
  },
  default_data:
    {key: null, nom: null, prenom: null, pseudo: null, index: null},
  items:null,
  panneau:null,

  // Pour créer une nouvelle donnée de personnage au curseur
  data_new_item:function(){
    var code = "PERSONNAGE:identifiant\n\tPRENOM: \n\tNOM: \n\tPSEUDO: \n\tDESCRIPTION: \n\tFONCTION: ";
    return {code: code, end: -65, length:11}
  },


  /** Ligne permettant de construire l'élément dans le listing
    * Propre à chaque élément, mais appelé par DataField pour construire
    * le panneau.
    */
  line_item_in_list:function(ip){
    var perso = this.items[ip];
    var line = '';
    line += DataField.mark_shortcut_for(ip);
    line += (perso.pseudo || ((perso.prenom||'') +' '+(perso.nom||'')).trim());
    line = "<li><a href='#' onclick=\"$.proxy(DataField,'insert_balise', Persos, "+ip+")();return false;\">" + line + '</a></li>';
    return line;
  },


  /** Capteur d'évènement keypress lorsque l'on se trouve dans
    * le champ des data des personnages
    */
  onkeypress:function(ev){
    // N0002 + N0005
    if(false == DataField.onkeypress(ev)){return false}
    return true;
  }


})
