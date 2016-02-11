/*
	FONCTION QUI CALCULE LA FACTURE EN FONCTION DES INFORMATIONS DONNÉES
*/
function calculer(from) {

	
	// Dernière définitions
	var montant_assurance = MontantAssurance(montant_ht)
	var montant_csg 			= MontantCSG(montant_ht);
	var montant_crds 			= MontantCRDS(montant_ht) ;
	$("#montant-assurance-maladie").html(montant_assurance) ;
	$("#montant-csg")			.html(montant_csg)   ;
	$("#montant-crds")		.html(montant_crds) ;

	//Remplir les champs
	$("#montant-ht")			.html(montant_ht) ;
	$("#montant-tva-5-5")	.html(pc_5_5) ;
	$("#total-TTC")				.html(montant_ttc) ;
	$("#97-pc-ht")				.html(pc97_ht) ;
	if (from != "net-a-payer")
	{
		if ( "undefined" == typeof montant_nap)
		{
			var montant_nap = montant_ttc
			 										- montant_assurance
			 										- montant_csg
			 										- montant_crds ;
		}
	}
	$("#net-a-payer").html(montant_nap) ;

	//- Faire apparaitre le bouton "Mettre en forme la facture"
	$('#btn-formater').show();
}

function MontantAssurance(montant_ht){
	return Math.round(montant_ht * 0.0085) ;
}
function MontantCSG(montant_ht){
	return Math.round(7.5 * (montant_ht * 0.97) / 100) ;
}
function MontantCRDS(montant_ht){
	return Math.round(0.5 * (montant_ht * 0.97) / 100) ;
}
/*
	Calcul d'après le net à payer (le plus compliqué)
	Cf. le calcul en bas de page
*/
function HT_From_NetAPayer(nap)
{
	var huitcinq  = 0.85 / 100 ;
	var neufsept  = 97   / 100 ;
	var septcinq  = 7.5  / 100 ;
	var zerocinq  = 0.5  / 100 ;

	// Calcul du montant hors-taxe approximatif
	var ht = Math.round(nap /	(1 + 0.055 - 0.0085 - (0.97 * 0.075) - (0.97 * 0.005)) ) ;

	var ht_init = "" + ht ;

	/*-----------------------------------------------------------------
		Le calcul n'est pas forcément juste (à cause des approximations).
		On vérifie et on l'affine si nécessaire
	------------------------------------------------------------------*/
	var new_nap = NAP_from_HT(ht) ;
	if ( new_nap == nap ) return ht ;

	ht = ht - 10 ; // Pour partir en dessous
	while (NAP_from_HT(ht) != nap ) { ++ht }

	return ht ;
}

function NAP_from_HT(ht)
{
	var pc_5_5 = Math.round(ht * 5.5 / 100) ;
	var ttc = ht + pc_5_5 ;
	return ttc - MontantAssurance(ht) - MontantCSG(ht) - MontantCRDS(ht) ;
}

var current_btn = null ;
function OnFocusMontant(suffixe){
	if ( current_btn != null ) $("btn/"+current_btn).setStyle({visibility:"hidden"});
	$("btn/"+suffixe).setStyle({visibility:"visible"});
	current_btn = suffixe ;
}
