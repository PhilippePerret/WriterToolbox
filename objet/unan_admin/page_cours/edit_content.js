if(undefined==window.PageCours){window.PageCours = new Object()}

$.extend(window.PageCours,{
  etat_normal: true,

  enable_shortcuts:function(){
    $('textarea#page_cours_content').bind('keypress',function(ev){
      PageCours.onkeypress(ev);
    })
  },
  disable_shortcuts:function(){
    $('textarea#page_cours_content').unbind('keypress')
  },

  onkeypress:function(ev){
    if(ev.metaKey){
      // F.show("Méta key avec touche " + ev.charCode);
      if(ev.charCode == 115 /* s */){
        // On enregistre le code
        ev.stopPropagation();
        ev.preventDefault();
        $('form#form_edit_page_cours').submit();
        return false
      } else if (ev.charCode == 112 /* P */){
        // Prévisualiser la page
        ev.stopPropagation();
        ev.preventDefault();
        var wnd = window.open('page_cours/'+this.page_id()+'/show?in=unan', 'visualisation_page_cours')
        return false
      }

    }
  },

  // Retourne le numéro de la page courante
  page_id:function(){
    return parseInt( $('input#page_id').val() );
  },

  toggle_interface:function(){
    if (this.etat_normal){
      this.set_interface();
    } else {
      this.unset_interface();
    }
  },
  // Régler l'interface pour qu'il se concentre sur la page à
  // éditer, en la fixant
  liste_objets_to_hide: [
    'section#header', 'section#footer', 'section#left_margin',
    'div#btns_admin_footer', 'div#bande_bas_de_page'
  ],
  set_interface:function(){
    UI.bloquer_la_page(true);
    $('textarea#page_cours_content').css({height: '600px', 'min-height':'600px'})
    // $(this.liste_objets_to_hide).each(function(i,o){
    //   $(o).hide();
    // })
    // $('section#content').css({
    //   'position': 'fixed',
    //   'top': '0',
    //   'left': '0',
    //   'margin': '0'
    // })
    // $('h1').css({'font-size': '15pt'});
  },
  // Remet l'interface dans sa position normale
  unset_interface:function(){
    UI.bloquer_la_page(false);
    $('textarea#page_cours_content').css({height: '100px'})
    // $(this.liste_objets_to_hide).each(function(i,o){
    //   $(o).show();
    // })
    // $('section#content').css({
    //   'position': 'relative',
    //   'top': null,
    //   'left': null,
    //   'margin-left': '134px'
    // })
    // $('h1').css({'font-size': '2.1em'});
  }

})


$(document).ready(function(){
  PageCours.etat_normal = $('input#interface_state').val() == "optimized";
  PageCours.etat_normal = !!PageCours.etat_normal ;
  PageCours.toggle_interface();


  Snippets.set_scopes_to([
    "text.html",
    {
      'paction' : { replace: "<p class=\"user_action\">\n$1\n</p>\n$0"}
    },
    "text.erb",
    {
      'work' : {replace:"WORK[$1|$2] $0"},
      'page' : {replace:"PAGE[$1|$2] $0"},
      'film' : {replace:"FILM[$1] $0"},
      'mot'  : {replace:"MOT[$1|$2] $0"}
    }
    ])

  $('textarea#page_cours_content').bind('focus',function(){
    Snippets.watch($(this));
    PageCours.enable_shortcuts();
  })
  $('textarea#page_cours_content').bind('blur',function(){
    Snippets.unwatch($(this));
    PageCours.disable_shortcuts();
  })

  $('textarea#page_cours_content').focus();
})
