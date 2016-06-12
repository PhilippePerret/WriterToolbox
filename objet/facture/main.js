if(undefined == window.Facture){window.Facture = {}}
$.extend(window.Facture,{

  // Méthode appelée au chargement de la page
  on_load_page:function(){
    $("*.hidden_when_calcul").hide();
  },

  /**
    * Méthode appelée pour calculer les montants de la facture
    *
    */
  calculer:function(){
    var montant_ht, montant_ttc, montant_net, pc_5_5, pc97_ht ;

    // Le type du montant fourni
    var montant_id = $('select#facture_montant_id').val() ;

    // Le montant fourni
    var montant_amount = $('input#facture_montant_amount').val().trim() ;
    if(montant_amount == ""){return F.error("Il faut fournir le montant de la facture !")}
    var montant_amount = parseInt(montant_amount);
    if ( isNaN(montant_amount) ) { return F.error("Le montant fourni doit être un nombre !") }

    switch( montant_id ){
      case 'montant_ht' :
        montant_ht  = montant_amount
    		pc_5_5      = Math.round(montant_amount * 5.5 / 100) ;
    		montant_ttc = montant_amount + pc_5_5 ;
        break;
      case 'montant_ttc' :
        montant_ttc = parseInt(montant_amount, 10) ;
    		montant_ht  = Math.round(100 * montant_ttc / 105.5) ;
        break;
      case 'montant_net' :
        montant_net = parseInt(montant_amount, 10);
    		montant_ht  = Facture.Calcul.montant_ht_from_net(montant_net) ;
        break;
    }

    // NOTE : montant_nap -> montant_net

    if (undefined == pc_5_5) 			{ pc_5_5 = Math.round(montant_ht * 5.5 / 100) }
    if (undefined == pc97_ht)			{ pc97_ht = Math.round(montant_ht * 97 / 100) }
    if (undefined == montant_ttc) { montant_ttc = montant_ht + pc_5_5 }

    // Dernière définitions
  	var montant_assurance = Facture.Calcul.montant_assurance(montant_ht)
  	var montant_csg 			= Facture.Calcul.montant_csg(montant_ht);
  	var montant_crds 			= Facture.Calcul.montant_crds(montant_ht) ;

    if (montant_id != "montant_net") {
      if ( undefined == montant_net){
        montant_net = montant_ttc
                      - montant_assurance
                      - montant_csg
                      - montant_crds ;
      }
    }

    this.montants = {
      'ht'        : montant_ht,
      'ttc'       : montant_ttc,
      'net'       : montant_net,
      'csg'       : montant_csg,
      'crds'      : montant_crds,
      'tva_5_5'   : pc_5_5,
      '97_pc_ht'  : pc97_ht,
      'maladie'   : montant_assurance
    }

    //Remplir les champs
    $(['ht', 'ttc', 'net', 'csg', 'crds', 'tva_5_5', '97_pc_ht', 'maladie']).each(function(i,o){
      Facture.set_amount(o)
    })
  },

  set_amount:function(montant_id){
    $('#montant_'+montant_id).html(this.montants[montant_id] + " €")
  },

  /**
    * Formate la facture
    *
    */
  formate:function(){

    var facture = $('div#div_facture');
    facture.removeClass('mode_calcul');
    facture.addClass('mode_print');

    // Tous les éléments qui étaient masqués pour le calcul
    // sont affichés
    $('.hidden_when_calcul').show();
    // Cacher tous les éléments inutiles au formatage
    $('.hidden_when_formate').hide();
    this.hide_ui_elements();

    // Mettre les informations
    this.set_informations();

    // On zoom en haut
    window.scroll(0,0);
  },

  /**
    * Pour mettre les informations de la facture
    */
  set_informations:function(){
    $('span#lieu_facture').html(this.getInfo('lieu'));
    var date = this.getInfo('date') ;
    if(date == ""){date = TODAY_HUMAN}
    $('span#date_facture')      .html(date);
    var emetteur_name = this.getInfo('emetteur_name')
    $('div#emetteur_facture')   .html(emetteur_name);
    $('div#signature_emetteur') .html(emetteur_name);
    $('pre#emetteur_adresse').html(this.getInfo('emetteur_adresse', 'textarea'));
    $('span#emetteur_statut').html(this.getInfo('emetteur_statut')); // p.e. "AUTEUR"
    $('div#client_name').html(this.getInfo('client_name'));
    $('pre#client_adresse').html(this.getInfo('client_adresse', 'textarea'));
    $('span#facture_numero').html(this.getInfo('facture_numero'));
    $('span#facture_objet').html(this.getInfo('facture_objet'));
  },

  getInfo:function(id, tagname){
    if(undefined == tagname){tagname = 'input'}
    return $(tagname+'#facture_'+id).val().trim();
  },

  /** Imprime la facture
    *
    */
  print:function(){
    $("*.hidden_when_print").hide() ;
    window.print();
    // Après l'impression, on peut remettre l'interface
    // dans son état normal.
    this.reset();
  },

  reset:function(){
    $('.hidden_when_formate').show();
    $('.hidden_when_calcul').hide();
    this.reset_ui_elements();
    facture.addClass('mode_calcul');
    facture.removeClass('mode_print');
    window.scroll(0,0);
  },

  /**
    * Quand on clique sur le bouton "Annuler" pour annuler
    * la mise en forme et donc l'impression.
    * On revient alors au mode normal pour entrer le montant
    * et le type de montant.
    */
  cancel:function(){this.reset()},

  // Pour cacher les éléments d'interface qui ne devront pas réapparaitre
  UI_ELEMENTS: [
    'section#header', 'section#left_margin', 'section#footer', 'h1'
  ],
  reset_ui_elements:function(){
    $(this.UI_ELEMENTS).each(function(i,o){$(o).show()})
    // On ajoute une classe à la section #content pour qu'elle
    // se comporte différemment
    $('body').removeClass('when_formate_facture')
  },
  hide_ui_elements:function(){
    $(this.UI_ELEMENTS).each(function(i,o){$(o).hide()})
    // On ajoute une classe au body (note : cela modifie aussi
    // des descendants)
    $('body').addClass('when_formate_facture')
  }

})

if(undefined == window.Facture.Calcul){ window.Facture.Calcul = {}}
$.extend(window.Facture.Calcul, {
	montant_assurance		:function(montant_ht){return Math.round(montant_ht * 0.0085)},
	montant_csg					:function(montant_ht){return Math.round(7.5 * (montant_ht * 0.97) / 100)},
	montant_crds				:function(montant_ht){return Math.round(0.5 * (montant_ht * 0.97) / 100)},
	montant_ht_from_net	:function(net){
		var huitcinq  = 0.85 / 100 ;
		var neufsept  = 97   / 100 ;
		var septcinq  = 7.5  / 100 ;
		var zerocinq  = 0.5  / 100 ;

		// Calcul du montant hors-taxe approximatif
		var ht = Math.floor(net /	(1 + 0.055 - 0.0085 - (0.97 * 0.075) - (0.97 * 0.005)) ) ;
		var ht_init = "" + ht ;
		/*-----------------------------------------------------------------
			Le calcul n'est pas forcément juste (à cause des approximations).
			On vérifie et on l'affine si nécessaire
		------------------------------------------------------------------*/
		var new_net = this.net_from_ht(ht) ;
		if ( new_net == net ) return ht ;
		ht = ht - 10 ; // Pour partir en dessous
		while (this.net_from_ht(ht) != net ) { ++ ht }
		return ht ;
	},
  // Retourne le montant NET à partir du montant HT
	net_from_ht: function(ht){
		var pc_5_5 = Math.round(ht * 5.5 / 100) ;
		var ttc = ht + pc_5_5 ;
		return ttc
			- this.montant_assurance(ht)
			- this.montant_csg(ht)
			- this.montant_crds(ht) ;
	}
})

/**
  * Exécuté au chargement de la page (en réalité : quand la
  * page a fini d'être chargée)
  */
$(document).ready(function(){

  Facture.on_load_page();

})
