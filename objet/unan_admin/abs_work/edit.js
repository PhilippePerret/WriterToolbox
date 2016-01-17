function on_change_type_general_travail(value){
  if(undefined == value){ value = $('select#work_typeW')[0].value }
  // Avant, on masquait/affichait le div pour les pages
  // cours ou les questionnaires, mais maintenant on fonctionne
  // avec un `item_id` donc ça n'est plus utile.
}
