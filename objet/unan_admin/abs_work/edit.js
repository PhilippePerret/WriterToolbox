function on_change_type_general_travail(value){
  if(undefined == value){ value = $('select#work_typeW')[0].value }
  // Avant, on masquait/affichait le div pour les pages
  // cours ou les questionnaires, mais maintenant on fonctionne
  // avec un `item_id` donc ça n'est plus utile.
}
if(undefined == window.AbsWork){window.AbsWork = {}}

$.extend(window.AbsWork,{

  // Initialisation du formulaire (pour nouveau travail)
  init_new:function(){
    var champs_valeurs = [
      'input#work_id',
      'input#work_titre',
      'input#work_duree',
      'input#work_item_id',
      'input#work_parent',
      'input#work_prev_work',
      'input#work_exemples',
      'input#work_points',
      'textarea#work_travail',
      'textarea#work_resultat'
    ];
    var champs_select = [
      'work_typeP',
      'work_type_w',
      'work_support',
      'work_destinataire',
      'work_niveau_dev'
    ]
    var champs_uncheck    = [];
    var champs_vide_html  = [];
    var champs_to_remove  = [];

    UI.init_form({
      val:      champs_valeurs,
      select:   champs_select,
      uncheck:  champs_uncheck,
      empty:    champs_vide_html,
      remove:   champs_to_remove
    })
  }
})
