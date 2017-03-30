window.CheckFormulaireDepot = function(){
  // Erreur si l'ID du film n'est pas défini
  var filmid_field = $('input#depot_film');
  if (filmid_field.val().trim() == ''){
    F.error('Il faut définir l’identifiant du film !');
    filmid_field.focus();
    return false;
  }
  // Erreur si aucun fichier scène n'est définir
  var scenes_field = $('input#file_depot[scenes][fichier]');
  debug(scenes_field.val());
  if (scenes_field.val() == ''){
    return F.error('Il faut choisir le fichier des scènes !');
  }
  return true;
}
