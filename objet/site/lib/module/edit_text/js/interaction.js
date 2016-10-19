if(undefined==window.EditText){window.EditText={}}

$.extend(window.EditText,{

  // Méthode appelée quand on clique sur la case "Snippets Markdown"
  // qui permet d'activer les snippets Markdown
  oncheck_snippets_markdown:function(is_checked){
    if(is_checked){
      F.show('Activation des snippets Markdown.');
    }else{
      F.show('Désactivation des snippets Markdown.');
    }
  },


  oncheck_snippets_narration:function(is_checked){
    if(is_checked){
      define_snippets_documents_narration();
      $('div#block_checkup_groups').show();
      F.show('Activation des snippets Narration.');
    }else{
      $('div#block_checkup_groups').hide();
      F.show('Désactivation des snippets Narration.')
    }

  }

})



$(document).ready(function(){
  EditText.textarea = $('textarea#file_content');
  EditText.set_interface();
  UI.prepare_champs_easy_edit(tous=true);
  // Pour vérifier que le code a bien été enregistré avant de
  // fermer la page.
	window.onbeforeunload = $.proxy(EditText,'before_quit');

  // Quand on focus sur la page, on doit focusser dans le
  // champ de texte principal contenant le texte de la page
  window.onfocus = function(){EditText.textarea[0].focus()}
})
