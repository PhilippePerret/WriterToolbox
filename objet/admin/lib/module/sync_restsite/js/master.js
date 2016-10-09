/**
  * Module Javascript principal
  * 9 oct 2016
  *
  */

/**
  * Méthode appelée par les boutons submit pour régler l'opération
  * avant de soumettre le formulaire.
  */
window.set_operation = function(operation){
  $('form#form_sync_restsite input#operation').val(operation);
  return true;
}
