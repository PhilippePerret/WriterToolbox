if(undefined == window.Facture){window.Facture = {}}
$.extend(window.Facture,{

  // Méthode appelée au chargement de la page
  on_load_page:function(){
    $("*.hidden-calcul").hide();
  },

  /**
    * Formate la facture
    *
    */
  formate:function(){

  	//-- On masque les textes inutiles
  	$('#page_facture').addClass("page-mode-facture");

  	// On affiche tous les éléments masqués par le calcul
  	$("*.hidden-calcul").show() ;
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

    // ---------------------------------------------------------------------
    //  CALCUL DES VALEURS DE LA FACTURE
    // ---------------------------------------------------------------------

    // On cache les boutons calculer
    this.hide_boutons_calcul();
  },
  hide_boutons_calcul:function(){
    $('a.btn_calcul').hide();
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
