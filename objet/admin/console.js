if(undefined==window.RSConsole){window.RSConsole = {}}

$.extend(window.RSConsole, {

  Snippets: {
    'URL': {replace:"http://www.laboiteaoutilsdelauteur.fr"},
    'tache': {replace:"new tache pour:Phil le:$1 tache: $2"}
  },

  console_field:function(){
    if (undefined == this._console_){
      this._console_ = $('textarea#console');
    }
    return this._console_;
  },
  console_val:function(){return this.console_field().val()},


  last_word_is_a_shortcut:function(lword){
    return {
      'URL': "http://www.laboiteaoutilsdelauteur.fr"
    }[lword]
  },

  // Type de commande détectée
  // Cela permet notamment d'envoyer des messages d'aide pour
  // certains type comme par exemple pour le tweet permanent
  // pour lequel a été implémentée cette fonctionnalité.
  type_command: null,

  // Indique la longueur du code tapé
  // Si la méthode détecte que c'est un tweet, elle décompte
  // le nombre de caractères
  compte_char:function(ev){
    if (ev.metaKey || ev.ctrlKey){return true}
    var last_word;
    var c = this.console_val() ;
    var words = c.split(' ');
    var nombre_mots = words.length;
    var first_word = words[0];
    var second_word = words[1];
    // if (words.length > 0){ last_word  = words[nombre_mots - 1] }
    this.detecte_sujet( first_word );
    // if( sc = this.last_word_is_a_shortcut(last_word) ){
    //   // On met le mot à la place
    //   words[nombre_mots - 1] = sc ;
    //   c = words.join(' ').trim() ;
    //   this.console_field().val(c);
    // }
    var l = c.length;
    if (this.sujet_courant == 'twitter'){
      // Cas d'un tweet
      l = l - first_word.length;
      var amorce = 'Tweet' ;
      // Y a-t-il des options ?
      if ( second_word == 'P' ){
        amorce += ' PERMANENT' ;
        l = l - 3 ;
        if (this.type_command != 'tweet permanent'){
          if(ONLINE){
            Flash.error("Noter que les tweets permanents doivent être enregistrés seulement en OFFLINE. Ce tweet ne sera pas enregistré.")
          }
          this.type_command = 'tweet permanent';
          Flash.show("Un tweet permanent est composé d'une “citation entre guillemets suivi d'un” lien bitly.");
        }
      } else {
        this.type_command = 'tweet'
      }

      reste = 140 - l ;
      mess = amorce + " : " + reste + " restants" ;
      if(reste < 0 && ev.keyCode != 8){
        $('span#longueur_code').css({color: 'red'})
        ev.preventDefault();
        return false;
      } else {
        $('span#longueur_code').css({color: 'inherit'})
      }
    } else {
      this.type_command = null ;
      mess = l.toString();
    }
    $('span#longueur_code').html(mess);
    return true;
  },

  /** Chaque fois qu'une lettre est tapée, on
    * détecte le sujet courant et, s'il change, on essaie
    * d'ajouter l'aide appropriée
    *
    * Pour le moment, je mets les textes d'aide ici mais il
    * sera possible plus tard de les relever par Ajax histoire
    * d'avoir les mêmes partout
    */
  KNOW_SUJETS: {
    'twit': 'twitter', 'tweet': 'twitter', 'tweete':'twitter',
    'test': 'test'
  },
  sujet_courant: null,
  detecte_sujet: function(tested){
    var sujet = this.KNOW_SUJETS[tested] ;
    if(undefined != sujet && sujet != this.sujet_courant){
      this.sujet_courant = sujet ;
      var aide = this.aide_by_sujet(sujet);
      $('pre#aide').html(aide + this.footaide());
    } else if (undefined == sujet && this.sujet_courant != null){
      this.sujet_courant = null;
      $('pre#aide').html('');
    }
  },

  footaide:function(){
    return "__\
__\
Pour ajouter de l'aide, éditer le fichier `console.js` __\
    "
  },
  aide_by_sujet:function(sujet){
    return {

      //
      // AIDE TESTS
      //
      test: " \
<strong>Commande `test <dossier>[ <online|offline>]`</strong> __\
    <dossier> : chemin relatif depuis ./test/ __\
`run test` pour jouer le fichier ./test/run.rb __\
__\
    <dossier> peut avoir la valeur de n'importe quel dossier __\
    dans ./test, dont : __\
      - mini  (tests minimum, à faire jouer après tout update) __\
      - moyen (tests un peu plus poussés) __\
      - deep  (tests profonds, par exemple tous les liens) __\
__\
    options : __\
        -v      Mode verbose : affiche le détail des cases __\
        -d      Mode documenté (pas encore implémenté)     __\
        -q      Mode quiet : affichage minimum.            __\
__\
__\
<strong>Commande : `test show db[ options]`</strong> __\
Pour afficher le contenu des bases de données à la fin des __\
tests (rappel : les bases de données sont backupées dans un) __\
dossier temporaire. __\
",

// AIDE TWITTER
      twitter: " \
Commande de base : `twit[ <option>] <message>` __\
URL site dans message : ... [URL]route/12/voir... __\
__\
Le comptage des lettres empêche de dépasser la limite des 140 caractères __\
mais il faut surveiller quand même avec les raccourcis. __\
__\
Pour obtenir une URL BITLY (lien court) rejoindre \\<a href='https://app.bitly.com/bitlinks/1TkHhvC' target='_blank'>Mon bitly\\</a> __\
__\
OPTIONS __\
------- __\
P : Transforme le tweet en 'tweet PERMANENT', c'est-à-dire en un __\
    tweet qui sera envoyé régulièrement de façon automatique __\
    Un tel tweet doit être composé d'une “citation” entre guillemets __\
    suivi d'un lien bitly vers la page du site concernée. __\
    Exemple : `twit P “Ceci est un extrait d'une page de cours” __\
                http://bitly/2546` __\
    L'opération n'est possible qu'en OFFLINE. __\
      "
    }[sujet].
      replace(/\\</g, '---SUPP---').
      replace(/</g,'&lt;').
      replace(/__/g,'<br />').
      replace(/---SUPP---/g, '<')
      ;
  }

})


/** AU READY DU DOCUMENT
  *
  */

$(document).ready(function(){

  $('textarea#console').bind('keypress', function(ev,ui){$.proxy(RSConsole,'compte_char', ev)()})

  if(undefined != window.Snippets){
    Snippets.set_scopes_to(
      [RSConsole.Snippets]
    );
    $('textarea#console').bind('focus', function(){Snippets.watch('textarea#console')})
    $('textarea#console').bind('blur',  function(){Snippets.unwatch('textarea#console')})
  }


})
