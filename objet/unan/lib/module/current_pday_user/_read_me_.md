# Current PDay de l'user

> Rappel : il ne s'agit pas d'un simple nombre mais d'une classe faite pour gérer le jour courant de l'auteur.

Ce dossier, dans les modules, est à charger pour des opérations spéciales comme par exemple pour connaitre l'état des lieux de l'auteur.

    Unan.require_module 'current_pday_user'

Mais le module est automatiquement chargé quand on appelle :

        User#current_pday

Appeler la méthode [up.current_pday.save_retard_program] pour enregistrer le retard du jour dans la donnée du programme.
