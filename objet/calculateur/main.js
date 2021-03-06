if(undefined==window.MOTS || 'function' != typeof window.MOTS.show ){

	window.MOTS = {
		show:function(mot_id){
			F.error("Pour le moment, on ne peut pas afficher les définitions des mots.<br>Merci de votre patience.")
			return false;
		}
	}

}
if(undefined==window.STT){window.STT = {}}

$.extend(window.STT, {

	calculeStructureIdeale:function(){

		var ParPages = $('select#pages_ou_minutes').val() == 'pages';
		var ParMinutes = !ParPages;
		var centaines 	= parseInt($('select#centaines').val()) * 100 ;
		var dizaines 		= parseInt($('select#dizaines').val()) * 10 ;
		var unites 			= parseInt($('select#unites').val()) ;

		var duree_film = centaines + dizaines + unites ;
		if ( duree_film == 0 ) {
			F.error("Il faut définir la durée du film ! (dans la première ligne de la table)") ;
			return ;
		}

		// Tous les span de class 'unite' doivent être renseignés
		// avec la valeur de l'unité et on règle le titre "entre…
		// et… "
		$('span.unite').html(ParPages ? 'page' : '') ;
		$('span.unite_a').html(ParPages ? 'page' : 'à') ;
		$('div#col_zone_titre').html(ParPages ? "Entre page… et page…" : "Entre minute… et minute…") ;

		/* Douzième et demi douzième */
		var douzieme 			= duree_film / 12 ;
		var demi_douzieme = douzieme / 2 ;


		var LParties = {} ;
		var do_end 	= Math.round(douzieme * 2 * 10 ) / 10 ;
		var pvt1 		= Math.round(douzieme * 3 * 10 ) / 10 ;
		LParties['duree_film']			= duree_film ;
		LParties['climax_end']			= duree_film ;
		LParties['incident_declencheur']= Math.round(douzieme * 10 ) / 10 ;
		LParties['do_start']			= Math.round(douzieme * 10 ) / 10 ;
		LParties['do_end']				= do_end ;
		LParties['pvt1']				= pvt1 ;
		LParties['pvt1_start']			= do_end ;
		LParties['pvt1_end']			= pvt1 ;
		LParties['expo_start']		= ParPages ? "1" : 0
		LParties['expo_end']			= ParPages ? parseInt(pvt1) : pvt1 ;
		var pvt2 = Math.round(douzieme * 9 * 10 ) / 10 ;
		var pvt2_start = Math.round(douzieme * 8 * 10 ) / 10 ;
		LParties['dev_start']			= ParPages ? parseInt(pvt1) : pvt1 ;
		LParties['dev_end']				= ParPages ? parseInt(pvt2) : pvt2 ;
		LParties['pvt2']					= pvt2 ;
		LParties['pvt2_start']		= pvt2_start ;
		LParties['pvt2_end']			= pvt2 ;
		LParties['den_start']			= ParPages ? parseInt(pvt2) : pvt2 ;
		LParties['den_end']				= ParPages ? parseInt(duree_film) : duree_film ;
		var climax_start = Math.round(douzieme * 11 * 10 ) / 10 ;
		LParties['climax_start']		= climax_start ;
		var cdv = (duree_film / 2) ;
		var cdv_start = Math.round((cdv - demi_douzieme) * 10) / 10 ;
		var cdv_end = Math.round((cdv + demi_douzieme) * 10 ) / 10 ;
		LParties['cdv_start']			= cdv_start ;
		LParties['cdv_end']				= cdv_end ;
		LParties['cdv']					= cdv ;

		/*= ON MET LES VALEURS DANS LES SPAN =*/
		for( var oid in LParties){
			var value = LParties[oid] ;
			if( ParPages ){ value = parseInt(value) }
			else { value = Time.s2h(Math.round(60*value)) }
			$('label#'+oid).html( value )
		}

	},

})

function STT_CalculStructureIdeale(DepuisMenuChangeUnite) {
}


$(document).ready(function(){

})
