if(undefined==window.Cnarration){window.Cnarration={}}
$.extend(window.Cnarration,{
  content_text_field: function(){
    if(undefined == this._content_text_field){
      this._content_text_field = $('textarea#file_content')
    }
    return this._content_text_field
  },
  container_checkup_groupes:function(){
    if(undefined== this._container_checkup_groupes){
      this._container_checkup_groupes = $('select#checkup_groups')
    }
    return this._container_checkup_groupes
  }
})
/**
  * Liste les groupes de checkup dans la page courante
  * de la série narration.
  *
  * Deux données doit être définies pour utiliser cette méthode :
  *   Cnarration.content_text_field   Le champ de texte jQuerry contenant le texte
  *   Cnarration.div_checkup_groupes  Le champ pour mettre les groupes. Peut être
  *                                   un select ou un div/span/p etc.
  */
window.liste_groupes_checkup_questions = function(){
  if(Cnarration.content_text_field().length == 0){
    return F.error('Il faut définir ou implémenter le champ Cnarration.content_text_field contenant le texte de la page.');
  }
  var code = Cnarration.content_text_field().val();
  var dest = Cnarration.container_checkup_groupes();
  if (dest.length == 0){
    return F.error('Il faut définir ou implémenter le champ Cnarration.div_checkup_groupes dans lequel mettre la liste des groupes de questions check-up.');
  }

  // On va chercher tous les CHECKUP[...|<groupe>]
  // var regexp = new RegExp("CHECKUP\[(?:.*)\|(.*)\]", 'g');
  var liste_groupes = [];
  var regexp = /CHECKUP\[(?:.*)\|(.*)\]/g;
  while(found = regexp.exec(code)){
    if(liste_groupes.indexOf(found[1]) == -1){liste_groupes.push(found[1])}
  }

  var options = [];
  for(var i=0,len=liste_groupes.length;i<len;++i){
    var groupe = liste_groupes[i];
    options.push('<option value="'+groupe+'">'+groupe+'</option>');
  }
  dest.html(options);

}
window.define_snippets_documents_narration=function(){

  Snippets.set_scopes_to(
    [{
      'doc': {replace:"\nDOC/events,scenario,synopsis,brut plain,rapport,procedure\n\n$0\n/Légende du document\n/DOC\n"},
      'p':    {replace:'personnage:|$0|'},
      'todo': {replace:"<adminonly>\nTODO: $0\n</adminonly>\n"},
      'q':    {replace:"CHECKUP[$1|$0]\n", func: window.liste_groupes_checkup_questions}

    }]
  )

}
