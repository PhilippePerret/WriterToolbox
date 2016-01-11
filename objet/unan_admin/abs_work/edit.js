function on_change_type_general_travail(value){
  if(undefined == value){ value = $('select#work_typeW')[0].value }

  $('div#div_pages_cours').hide();
  $('div#div_questionnaires').hide();

  switch(value){
    case '3': // pages de cours
      $('div#div_pages_cours').show()
      break;
    case '5': // Checklists
    case '4': // Questionnaires
      $('div#div_questionnaires').show();
      break;
  }
}
