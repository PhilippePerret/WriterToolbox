if(undefined==window.Exemple){window.Exemple={}}

$.extend(window.Exemple,{

  init_new:function(){
    // F.show('Init new fonctionne mal. Utiliser plutôt le bouton')
    // var hfields = {}
    // hfields.val = [
    //   "input#exemple_id", "input#exemple_titre",
    //   "textarea#exemple_content", "textarea#exemple_notes",
    //   "input#exemple_source_year", "input#exemple_work_id",
    //   "input#exemple_source"
    // ];
    // hfields.select = [
    //   "exemple_sujet", "exemple_source_src", "exemple_source_pays"
    // ];
    // UI.init_form(hfields);
    // $('input#exemple_id').val('');
    window.location.href = 'exemple/edit?in=unan_admin';
  },

  /** Méthode appelée quand on clique sur la case à cocher
    * 'Syntaxe markdown'
    * Elle ajoute ou retire la balise "<!-- MARKDOWN -->" pour
    * indiquer que le code est en markdown (ou non)
    */
  toggle_markdown:function(is_markdown){
    var o = $('textarea#exemple_content');
    var content ;
    if (is_markdown) {
      content = "<!-- MARKDOWN -->\n\n" + o.val();
    } else {
      content = o.val().replace(/^<!-- MARKDOWN -->/, '').trim();
    }
    o.val(content);
  }

})


$(document).ready(function(){

  // Réglage des snippets
  Snippets.set_scopes_to(['text.html']);
  $('textarea#exemple_content').bind('focus', function(){Snippets.watch($(this))})
  $('textarea#exemple_content').bind('blur', function(){Snippets.unwatch($(this))})
  $('textarea#exemple_notes').bind('focus', function(){Snippets.watch($(this))})
  $('textarea#exemple_notes').bind('blur', function(){Snippets.unwatch($(this))})

  // Bloquer la fenêtre pour une édition plus confortable
  UI.bloquer_la_page(true)
})
