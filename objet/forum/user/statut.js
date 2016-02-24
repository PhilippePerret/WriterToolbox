if(undefined==window.User){window.User = {}}

$.extend(window.User, {

  user_id: null,

  // Quand on clique sur le grade de l'user, pour le changer
  // La méthode affiche un menu des grades, avec un bouton pour
  // le modifier.
  on_click_grade: function(lien){
    lien = $(lien) ;
    this.user_id    = lien.attr('data-user') ;
    var grade       = lien.attr('data-grade') ;
    var container   = $('span#span_grade-'+this.user_id)
    var menu_grade  = $('select#menu_grades') ;
    // Déplacer le menu à la place du lien
    container.append( menu_grade ) ;
    // Masquer le lien
    lien.hide() ;
    // Régler le menu à la valeur du grade
    menu_grade.val( grade ) ;

  },

  on_change_grade:function(menu){
    var grade = $(menu).val();
    window.location.href = "user/"+this.user_id+"/statut?in=forum&v=" + grade ;
  }

})
