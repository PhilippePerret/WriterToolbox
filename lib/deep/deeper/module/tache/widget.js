if(undefined==window.TachesWidget){window.TachesWidget={}}

$.extend(window.TachesWidget,{

  create_tache:function(){
    F.clean();
    F.show("Enregistrement de la tâche…");
    // On met le titre de la page dans le champ de
    // formulaire hidden
    var grand_titre = $('section#content h1').first().html();
    var titre_page  = $('section#content h2').first().html();
    var titre = grand_titre + "::" + titre_page ;
    $('input#tache_titre_page').val( titre );
    Ajax.submit_form('taches_widget');
  }
})