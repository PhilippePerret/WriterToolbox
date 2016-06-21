if(undefined == window.Sync){window.Sync = {}}

$.extend(window.Sync,{

  // Décoche toutes les cases à cocher des synchros
  decoche_all: function(){
    $('div#liste_synchros input[type="checkbox"]').each(function(){
      cb = $(this)[0];
      cb.checked = false ;
    })
  },

  // Code toutes les synchros
  coche_all:function(){
    $('div#liste_synchros input[type="checkbox"]').each(function(){
      cb = $(this)[0];
      cb.checked = true ;
    })
  },

  // Inverse les cochages des synchros à faire
  inverse_all: function(){
    $('div#liste_synchros input[type="checkbox"]').each(function(){
      cb = $(this)[0];
      cb.checked = !cb.checked ;
    })
  }

})
