if(undefined == window.PageCours){window.PageCours = {}}

$.extend(window.PageCours, {

  set_operation:function(ope, soumettre){
    $('form#form_edit_page_cours input#operation').val(ope);
    if(soumettre){$('form#form_edit_page_cours').submit()}
  },

  // Méthode qui indique le path qui sera utilisé pour chercher
  // la page (le texte). Ce path dépend du type de page, à savoir
  // si c'est une page du programme ou une page de la collection
  // narration.
  set_folder_path:function(){
    // Le div pour inscrire le path
    var div = $('div#folder_page_path') ;
    // Le menu contenant le type
    var menu = $('select#page_cours_type') ;
    var type = menu.val();
    var path_type;
    if(type == 'U'){path_type = 'program'}
    else if (type == 'N'){path_type = 'cnarration'}
    else {F.error("Le type " + type + " est inconnu. Impossible de régler le path du dossier."); return}
    div.html("./data/unan/pages_cours/"+path_type+"/");
  }
})
Object.defineProperties(window.PageCours,{

})

function set_href_lien_read(o){
  var href_pref = "page_cours/" + o.value + "/";
  var href_read = href_pref + "show?in=unan"  ;

  $('a#lien_read_page').attr('href', href_read) ;
}

$(document).ready(function(){
  PageCours.set_folder_path() ;
})
