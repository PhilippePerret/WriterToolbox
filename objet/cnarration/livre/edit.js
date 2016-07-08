if(undefined==window.Cnarration){window.Cnarration = {}}

$.extend(window.Cnarration,{

  /**
    * Méthode principale appelée par le bouton "Enregistrer" pour
    * enregistrer la table des matières courante
    */
  save_tdm:function(livre_id){
    // On commence par relever l'ordre des pages et titres
    liste_ids = this.get_ids_list();
    self.window.location.href = "livre/"+livre_id+"/save_tdm?in=cnarration&ids="+liste_ids.join('-')
  },
  save_tdm_poursuivre:function(rajax){
    if (rajax.ok ){F.show("Table des matières enregistrée.")}
    else {F.error("Une erreur s'est produite…")}
  },

  /**
    * Méthode appelée quand on finit de déplacer un élément de la
    * table des matières en tenant la touche majuscule appuyée.
    * Cela déplace tous les sous-éléments de l'élément.
    *
    * @list_init  {Array} Liste initiale des IDs dans la table
    *             des matières.
    */
  move_subitems_of:function(li, list_init){
    F.clean();
    var main_item_id    = li.attr('data-id') ;
    var main_item_class = li.attr('class') ;
    var main_item_niv ;
    // Si l'item déplacé a un niveau de 1, il n'a pas de sous-éléments
    if(li.hasClass('niv1')){
      F.error("L'élément " + main_item_id + " n'a pas de sous-éléments à déplacer.");
      return
    } else if (li.hasClass('niv2')){
      main_item_niv = 2
    } else if (li.hasClass('niv3')){
      main_item_niv = 3
    } else {
      return F.error("IMPOSSIBLE D'OBTENIR LE NIVEAU DE L'ÉLÉMENT #" + main_item_id +" … BIZARRE…")
    }

    F.show("L'élément " + main_item_id + " a des sous-éléments") ;

    // Ordre actuel des éléments
    var list_actu = this.get_ids_list();

    // On déplace les sous-éléments
    // Pour procéder, on consulte les éléments qui suivent l'élément
    // déplacer et on conserver tous ceux qui on un niveau (class)
    // supérieur.

    // On prend le décalage de l'élément dans la liste
    var offset_main_item = list_init.indexOf( main_item_id );

    // On boucle sur tous les items suivants jusqu'à trouver un
    // item de même niveau ou supérieur
    var subitem_id, subitem, subitem_class, subitem_niv ;
    var subitems_list = new Array();
    for(var i = (offset_main_item + 1), len = list_init.length; i < len; ++i){
      subitem_id = list_init[i] ;
      subitem = $('li[data-id="'+subitem_id+'"]') ;
      subitem_class = subitem.attr('class') ;
      subitem_niv   = parseInt(subitem_class.substring(3, 4));
      if(isNaN(subitem_niv) || subitem_niv < 1 || subitem_niv > 3){
        F.error("La classe de l'élément " + subitem_id + " est mauvaise ('"+subitem_class+"'). Impossible de trouver son niveau, je dois renoncer.");
        return ;
      }

      // Si le niveau de l'élément courant testé est supérieur à
      // l'élément principal déplacé, on peut s'arrêter là.
      // Sinon on ajoute le sous-élément à la liste
      if( subitem_niv >= main_item_niv ){
        break ;
      } else {
        subitems_list.push( subitem_id )
      }
    }; // Fin de boucle

    // Si la liste des sous-éléments est vide, il n'y a rien à
    // faire.
    // Sinon, on déplace aussi tous les sous-éléments.
    if (subitems_list.length){
      var offset_main_item_actu = list_actu.indexOf( main_item_id );
      current_item = li ;
      for(i in subitems_list){
        subitem_id = subitems_list[i] ;
        subitem = $('li[data-id="'+subitem_id+'"]') ;
        subitem.insertAfter(current_item) ;
        current_item = subitem ;
      }
    }
  },

  /** Retourne la liste actuelle des éléments dans la table
    * des matières.
    */
  get_ids_list:function(){
    var l = [];
    $('ul#editable_tdm > li').each(function(){
      var o = $(this);
      var id = o.attr('data-id')
      if(
        id != "0"/* délimiters quand liste vide */
        &&
        id != null /* quand déplacement en cours par exemple */
      ){ l.push(id) }
    })
    return l;
  }

})

$('document').ready(function(){

  $('ul#editable_tdm').sortable({

    // Propriété personnelle indiquant si le déplacement doit
    // se faire avec les sous-éléments ou non.
    with_sous_elements: false,
    // Propriété personnelle contenant la liste des IDs initial
    list_init: null,

    connectWith: '.livre_tdm',

    start:function(ev, ui){
      if(ev.shiftKey == true){
        this.with_sous_elements = true
        this.list_init = Cnarration.get_ids_list();
        F.show("MAJ => Déplacement avec sous-éléments.")
      }
    },
    sort:function(ev,ui){
      if(this.with_sous_elements && false == ev.shiftKey){
        F.clean();
        F.show("Abandon du déplacement groupé.");
        this.with_sous_elements = false
      }
    },
    update: function(ev, ui){
      if( this.with_sous_elements && true == ev.shiftKey ){
        //
        Cnarration.move_subitems_of(ui.item, this.list_init);
        // On ré-initialise
        this.with_sous_elements = false
      }
    }
  })

  $('ul#pages_et_titres_out').sortable({
    connectWith: '.livre_tdm'
  })
})

$(document).ready(function(){UI.bloquer_la_page(true)})
