# Ajax

* [Auto-sélection du contenu des champs de texte quand focus](#autoselectquandfocus)



<a name='autoselectquandfocus'></a>

## Auto-sélection du contenu des champs de texte quand focus

Pour obtenir que les champs de texte (input-text et textarea) se sélectionnent quand on focus dedans, on peut utiliser la méthode :

  UI.auto_selection_text_fields()

Noter qu'elle est déjà appelée par défaut au chargement de la page, donc qu'elle n'est à utiliser que lorsqu'on recharge du texte par ajax.
