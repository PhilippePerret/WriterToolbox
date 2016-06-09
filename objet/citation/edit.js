if(undefined == window.Citation){window.Citation = {}}

$.extend(window.Citation,{


  on_keypress_description:function(ev){
    if(ev.keyCode == 13){
      this.overview_description();
    }
  },

  overview_description:function(){
    console.log("-> overview_description")
    var code = $('textarea#citation_description').val();
    $('div#overview_description').html(code);
  },

  mettre_en_forme_description:function(){
    console.log("-> mettre_en_forme_description")
    var code = $('textarea#citation_description').val();
    code = code.replace(/<\/p><p( |>)/g, function(m, p1){
      return "</p>\n\n<p" + p1
    })
      .replace(/<\/p>/g, "\n</p>")
      .replace(/<p(.*)>/g, function(m, p1){return "<p"+p1+">\n"})
    $('textarea#citation_description').val(code);
  }

})

$(document).ready(function(){

  $('textarea#citation_description').bind('focus', function(){
    console.log("-> focus description")
  })
  $('textarea#citation_description').bind('blur', function(){
    console.log("-> blur description")
    Citation.overview_description()
  })
  $('textarea#citation_description').bind('keypress', function(ev, ui){
    Citation.on_keypress_description(ev)
  })

  // On met également en forme la description pour qu'elle soit plus lisible
  Citation.mettre_en_forme_description()

})