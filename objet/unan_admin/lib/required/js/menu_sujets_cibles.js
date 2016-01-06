// ul.sujets_cibles
$(document).ready(function(){
  if($('ul.sujets_cibles').length){
    var menu = $('ul.sujets_cibles');
    var parent = menu.parent();
    var id_parent = parent.attr('id') ;
    // L'ID du champ hidden qui doit recevoir la valeur
    // du sujet cible (à deux chiffres)
    // Note : Il sert également à construire l'identifiant du
    // champs span qui contient et affiche la valeur humaine
    var hidden_field_id = menu.attr('hidden-field-id') ;
    var span_human_id   = hidden_field_id + '_human' ;
    // Le champ hidden qui va conserver la valeur de la cible
    // composé de deux chiffres, le premier pour le sujet et
    // le second pour le sous-sujet
    var champ_hidden = $('input[type="hidden"]#' + hidden_field_id) ;
    var champ_valeur_humaine = $('span#'+span_human_id) ;
    $('ul.sujets_cibles li.subitem').each(function(){
      $(this).bind('click', function(){
        var li_parent = $(this).parent().parent();
        var parent_span_name = li_parent.find('> span.item_name') ;
        var valeur_humaine = parent_span_name.html() + "::" + $(this).html() ;
        var sujet_value = $(this).attr('sujet-value') ;
        var sub_value   = $(this).attr('value') ;
        // On mémorise la valeur dans le champ caché
        champ_hidden.val( sujet_value + sub_value ) ;
        // On affiche la valeur humaine
        champ_valeur_humaine.html(valeur_humaine);
      })
    })
  }
})
