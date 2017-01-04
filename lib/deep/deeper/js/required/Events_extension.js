
/**
  * Permet de stopper complètement un évènement pour qu'il ne se
  * propage pas à ses parents et que son comportement par défaut
  * ne soit pas activé.
  * La méthode retourne FALSE pour pouvoir l'utiliser simplement
  * dans les méthodes d'évènements par :
  *     return stop_event(evenment);
  */
function stop_event(ev){
  ev.preventDefault();
  ev.stopPropagation();
  return false;
}
