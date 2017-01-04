if(undefined==window.Brins){window.Brins={}}
$.extend(window.Brins,{

  // Valeurs obligatoires définissant l'élément pour DataField
  // Cf. Le _REFBOOK_ dans ce dossier
  name: 'Brins',
  type: 'brin', tag: 'BRIN',
  items: null,
  panneau: null,
  strings:{
    pluriel: 'brins'
  },
  default_data: {key: null, titre: null, description: null, index: null},


  // Pour créer une nouvelle donnée de brin au curseur
  data_new_item:function(){
    var code = "BRIN:identifiant\n\tTITRE: \n\tBTYPE: \n\tDESCRIPTION: ";
    return {code: code, end: -44, length:11}
  },
  // Ligne permettant de construire l'élément +ip+ dans le listing
  line_item_in_list:function(ip){
    var brin = this.items[ip];
    var line = '';
    line += DataField.mark_shortcut_for(ip);
    line += brin.titre ;
    line = "<li><a href='#' onclick=\"$.proxy(DataField,'insert_balise', Brins, "+ip+")();return false;\">" + line + '</a></li>';
    return line;
  },

  onkeypress:function(ev){
    // N0002 + N0005
    if(false == DataField.onkeypress(ev)){return false}

    return true;
  },

})
