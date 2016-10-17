if(undefined==window.EditText){window.EditText={}}
$.extend(window.EditText,{
  textarea: null,
  modified: false,

  set_interface: function(){
    $('section#header').hide();
    $('section#footer').hide();
    $('section#left_margin').hide();
    $('form#taches_widget').hide();
    $('div#div_pastille_taches').hide();
    $('div#hrefs').hide();
    this.textarea.css({
      height : (window.innerHeight - 100)+'px'
    })
  },

  onchange_police:function(police){
    this.textarea.css('font-family', police);
  },
  onchange_lineheight:function(height){
    this.textarea.css('line-height', height+'em')
  },

  // Pour chercher un mot
  cherche_scenodico:function(extrait, rajax){
    if(undefined == rajax){
      if(undefined == extrait){extrait = $('input#scenodico').val()}
      Ajax.send({
        route:      'scenodico/search',
        search:     {search: extrait, in_mot: 'on'},
        operation:  'search_scenodico',
        onreturn:   $.proxy(EditText,'cherche_scenodico',extrait)
      })
    }else{
      if (undefined == rajax.mots || rajax.mots.length == 0){
        // Aucun résultat
        // --------------
        F.error("Aucun mot n'a pu être trouvé à partir de "+extrait+"…")
      }else if(rajax.mots.length == 1){
        // Un seul résultat
        // ----------------
        mot   = rajax.mots[0];
        lien  = "MOT["+mot.id+"|"+mot.mot.lowerCase()+"]";
        $('input#scenodico').val(lien).focus();
      }else{
        // Plusieurs résultats
        // -------------------
        // On les présente dans un menu pour en choisir un
        $(rajax.menu_mots.replace(/_ONCHANGE_/,"$.proxy(EditText,'onchoose_scenodico',this.value)()")).insertAfter($('input#scenodico'));
      }
    }
  },

  // Pour chercher un mot
  cherche_filmodico:function(extrait, rajax){
    if(undefined == rajax){
      if(undefined == extrait){extrait = $('input#filmodico').val()}
      Ajax.send({
        route:        'filmodico/search',
        filmsearch:    {sought: extrait, in_titre: 'on'},
        operation:    'proceed_search',
        onreturn:     $.proxy(EditText,'cherche_filmodico',extrait)
      })
    }else{
      if (undefined == rajax.films || rajax.films.length == 0){
        // Aucun résultat
        // --------------
        F.error("Aucun film n'a pu être trouvé à partir de "+extrait+"…")
      }else if(rajax.films.length == 1){
        // Un seul résultat
        // ----------------
        film   = rajax.films[0];
        lien  = "FILM["+film.film_id+"]";
        $('input#filmodico').val(lien).focus();
      }else{
        // Plusieurs résultats
        // -------------------
        // On les présente dans un menu pour en choisir un
        $(rajax.menu_films.replace(/_ONCHANGE_/,"$.proxy(EditText,'onchoose_filmodico',this.value)()")).insertAfter($('input#filmodico'));
      }
    }
  },

  // Quand on choisit le mot dans le menu
  onchoose_scenodico:function(link){
    $('input#scenodico').val(link);
    $('input#scenodico').focus();
  },

  // Quand on choisit le film dans le menu (s'il y a plusieurs films)
  onchoose_filmodico:function(link){
    $('input#filmodico').val(link);
    $('input#filmodico').focus();
  },

  // Méthode principale pour enregistrer le texte. Ça l'envoie par
  // ajax, en espérant qu'on atteigne pas la limite.
  // On vérifie quand même
  on_save_text:function(rajax){
    if(undefined == rajax){
      Ajax.submit_form('form_edit_text', $.proxy(EditText,'on_save_text'));
    }else{
      window.set_modified(false);
    }
  },

  before_quit:function(e){
    if(false == window.text_modified){
      e.returnValue = null ;
      return; // ça ne fonctionne pas : le message est affiché
    }
    var e = e || window.event;
     if (e) {
       // IE, Firefox (< 49 ?)
       e.returnValue = 'Voulez-vous vraiment quitter cette page ?';
     }
     // Safari
     return 'Voulez-vous vraiemnt quitter cette page ?';
   }

});

window.text_modified = false ;
window.set_modified = function(value){
  window.text_modified = !!value;
}


$(document).ready(function(){
  EditText.textarea = $('textarea#file_content');
  EditText.set_interface();
  UI.prepare_champs_easy_edit(tous=true);
  // Pour vérifier que le code a bien été enregistré avant de
  // fermer la page.
	window.onbeforeunload = $.proxy(EditText,'before_quit');

})
