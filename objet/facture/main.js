if(undefined == window.Facture){window.Facture = {}}
$.extend(window.Facture,{

  // Méthode appelée au chargement de la page
  on_load_page:function(){
    $("*.hidden_when_calcul").hide();
  },

  /**
    * Formate la facture
    *
    */
  formate:function(){

  	//-- On masque les textes inutiles
  	$('#page_facture').addClass("page-mode-facture");
  	// On affiche tous les éléments masqués par le calcul
  	$("*.hidden_when_calcul").show() ;
  	// On masque tous les éléments propres au calcul
  	$("*.hidden-facture").hide() ;
  	// On affiche les informations d'entête et on règle la
    // date à aujourd'hui
  	$('#entete_facture').show();
  	$('#date_facture').html(TODAY_HUMAN) ;
  	// Mise en forme de la partie chiffrée
  	$('div#div-partie-chiffree').addClass("page_format_facture") ;
  },

  /** Imprime la facture
    *
    */
  imprime:function(){
    $("*.hidden-print").hide() ;
    window.print();
  },

  /**
    * Méthode appelée pour calculer les montants de la facture
    *
    */
  calculer_with:function(montant_id){

    var montant_ht, montant_ttc, montant_net, pc_5_5, pc97_ht ;

    // Le montant fourni
    var montant_field   = $( 'input#facture_' + montant_id )
    var montant_amount  = parseInt(montant_field.val());
    if ( isNaN(montant_amount) ) { alert("Il faut fournir un nombre !") ; return false }

    switch( montant_id ){
      case 'montant_ht' :
        montant_ht  = parseInt(montant_amount, 10) ;
    		pc_5_5      = Math.round(montant_amount * 5.5 / 100) ;
    		montant_ttc = montant_amount + pc_5_5 ;
        break ;
      case 'montant_ttc' :
        montant_ttc = parseInt(montant_amount, 10) ;
    		montant_ht  = Math.round(100 * montant_ttc / 105.5) ;
        break ;
      case 'montant_net' :
        montant_net = parseInt(montant_amount, 10);
    		montant_ht  = HT_From_NetAPayer(montant_net) ;
        break ;
    }

    // NOTE : montant_nap -> montant_net

    if (undefined == pc_5_5) 			{ pc_5_5 = Math.round(montant_ht * 5.5 / 100) }
    if (undefined == pc97_ht)			{ pc97_ht = Math.round(montant_ht * 97 / 100) }
    if (undefined == montant_ttc) { montant_ttc = montant_ht + pc_5_5 }

    // Dernière définitions
  	var montant_assurance = Facture.Calcul.montant_assurance(montant_ht)
  	var montant_csg 			= Facture.Calcul.montant_csg(montant_ht);
  	var montant_crds 			= Facture.Calcul.montant_crds(montant_ht) ;
  	$("#montant-assurance-maladie").html(montant_assurance) ;
  	$("#montant-csg")			.html(montant_csg)   ;
  	$("#montant-crds")		.html(montant_crds) ;


    //Remplir les champs
    $("#montant-ht")			.html(montant_ht) ;
    $("#montant-tva-5-5")	.html(pc_5_5) ;
    $("#total-TTC")				.html(montant_ttc) ;
    $("#97-pc-ht")				.html(pc97_ht) ;
    if (montant_id != "montant_net") {
      if ( undefined == montant_net){
        montant_net = montant_ttc
                      - montant_assurance
                      - montant_csg
                      - montant_crds ;
      }

      $("#net-a-payer").html(montant_net) ;
    }

    // On cache les boutons calculer
    this.hide_boutons_calcul();
  },
  hide_boutons_calcul:function(){
    $('a.btn_calcul').hide();
  }
})

if(undefined == window.Facture.Calcul){ window.Facture.Calcul = {}}
$.extend(window.Facture.Calcul, {
	montant_assurance		:function(montant_ht){return Math.round(montant_ht * 0.0085)},
	montant_csg					:function(montant_ht){return Math.round(7.5 * (montant_ht * 0.97) / 100)},
	montant_crds				:function(montant_ht){return Math.round(0.5 * (montant_ht * 0.97) / 100),
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
  Facture.hide_boutons_calcul();
  // On cache les boutons "Calculer" qu'on ne montre que lorsque
  // l'on focusse dedans
  $('input.montant_field').bind('focus', function(){
    $('a.btn_calcul').hide();
    var field_id = $(this).attr('id') ;
    field_id = field_id.substr(8, field_id.length-1);
    F.show(field_id);
    var btn_calcul = $('a#btn_calcul_'+field_id);
    btn_calcul.show();
  })

  Facture.on_load_page();

})
