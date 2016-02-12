

var current_btn = null ;
function OnFocusMontant(suffixe){
	if ( current_btn != null ) $("btn/"+current_btn).setStyle({visibility:"hidden"});
	$("btn/"+suffixe).setStyle({visibility:"visible"});
	current_btn = suffixe ;
}
