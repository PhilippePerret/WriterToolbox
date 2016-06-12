if(undefined==window.PageCours){window.PageCours = new Object()}

$.extend(window.PageCours,{
  etat_normal: true,

  toggle_interface:function(){
    if (this.etat_normal){
      this.set_interface();
    } else {
      this.unset_interface();
    }
    this.etat_normal = !this.etat_normal ;
    $('input#interface_state').val(this.etat_normal ? 'not_optimized' : 'optimized')
  },
  // Régler l'interface pour qu'il se concentre sur la page à
  // éditer, en la fixant
  liste_objets_to_hide: [
    'section#header', 'section#footer', 'section#left_margin',
    'div#btns_admin_footer', 'div#bande_bas_de_page'
  ],
  set_interface:function(){
    $(this.liste_objets_to_hide).each(function(i,o){
      $(o).hide();
    })
    $('section#content').css({
      'position': 'fixed',
      'top': '0',
      'left': '0',
      'margin': '0'
    })
    $('h1').css({'font-size': '15pt'});
    $('a#btn_optimize').html("Ré-initialise l'interface");
  },
  // Remet l'interface dans sa position normale
  unset_interface:function(){
    $(this.liste_objets_to_hide).each(function(i,o){
      $(o).show();
    })
    $('section#content').css({
      'position': 'relative',
      'top': null,
      'left': null,
      'margin-left': '134px'
    })
    $('h1').css({'font-size': '2.1em'});
    $('a#btn_optimize').html("Optimise l'interface");
  }

})


$(document).ready(function(){
  PageCours.etat_normal = $('input#interface_state').val() == "optimized";
  PageCours.etat_normal = !PageCours.etat_normal ;
  PageCours.toggle_interface();

  Snippets.set_scopes_to([
    "text.html",
    "text.erb",
    {
      'work' : {replace:"[work::$1::$2] $0"},
      'page' : {replace:"[page::$1::$2] $0"},
      'film' : {replace:"[film::$1] $0"},
      'mot'  : {replace:"[mot::$1::$2] $0"}
    }
    ])

  $('textarea#page_cours_content').bind('focus',function(){
    Snippets.watch($(this))
  })
  $('textarea#page_cours_content').bind('blur',function(){
    Snippets.unwatch($(this))
  })

})
