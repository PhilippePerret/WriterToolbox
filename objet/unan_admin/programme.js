if(undefined == window.MapProgramme){window.MapProgramme = {}}
$.extend(window.MapProgramme,{

  /**
    * Méthode pour ouvrir/fermer les items d'un élément
    */
  toggle: function(o){
    $(o).next().toggle();
  }
})
