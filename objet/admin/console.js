if(undefined==window.RSConsole){window.RSConsole = {}}

$.extend(window.RSConsole, {

  // Indique la longueur du code tapé
  // Si la méthode détecte que c'est un tweet, elle décompte
  // le nombre de caractères
  compte_char:function(ev){
    if (ev.metaKey || ev.ctrlKey){return true}
    var c = $('textarea#console').val();
    var first_word = c.split(' ')[0];
    var l = c.length;
    var is_twitter = ['twit', 'tweet', 'twitte', 'twitter'].indexOf(first_word) > -1;
    if (is_twitter){
      l = l - first_word.length;
      reste = 140 - l ;
      mess = "Tweet : " + reste + " restants"
      if(reste < 0 && ev.keyCode != 8){
        $('span#longueur_code').css({color: 'red'})
        ev.preventDefault();
        return false;
      } else {
        $('span#longueur_code').css({color: 'inherit'})
      }
    } else {
      mess = l.toString();
    }
    $('span#longueur_code').html(mess);
    return true;
  }

})

$(document).ready(function(){
  $('textarea#console').bind('keypress', function(ev,ui){$.proxy(RSConsole,'compte_char', ev)()})
})
