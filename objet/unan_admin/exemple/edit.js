if(undefined==window.Exemple){window.Exemple={}}

$.extend(window.Exemple,{

  init_new:function(){
    var hfields = {}
    hfields.val = [
      "input#exemple_id", "input#exemple_titre",
      "textarea#exemple_content", "textarea#exemple_notes",
      "input#exemple_source_year", "input#exemple_work_id",
      "input#exemple_source"
    ];
    hfields.select = [
      "exemple_sujet", "exemple_source_src", "exemple_source_pays"
    ];
    UI.init_form(hfields);
  }

})


$(document).ready(function(){

  Snippets.set_scopes_to(['text.html']);

  $('textarea#exemple_content').bind('focus', function(){Snippets.watch($(this))})
  $('textarea#exemple_content').bind('blur', function(){Snippets.unwatch($(this))})

  $('textarea#exemple_notes').bind('focus', function(){Snippets.watch($(this))})
  $('textarea#exemple_notes').bind('blur', function(){Snippets.unwatch($(this))})

})
