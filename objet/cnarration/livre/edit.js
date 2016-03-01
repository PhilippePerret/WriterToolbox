if(undefined==window.Cnarration){window.Cnarration = {}}

$.extend(window.Cnarration,{

  /**
    * Méthode principale appelée par le bouton "Enregistrer" pour
    * enregistrer la table des matières courante
    */
  save_tdm:function(livre_id){
    // On commence par relever l'ordre des pages et titres
    var liste_ids = [];
    $('ul#editable_tdm > li').each(function(){
      var o = $(this);
      var id = o.attr('data-id')
      if(id != "0"/* délimiters quand liste vide */){ liste_ids.push(id) }
    })
    self.window.location.href = "livre/"+livre_id+"/save_tdm?in=cnarration&ids="+liste_ids.join('-')
  },
  save_tdm_poursuivre:function(rajax){
    if (rajax.ok ){F.show("Table des matières enregistrée.")}
    else {F.error("Une erreur s'est produite…")}
  }

})

$('document').ready(function(){

  $('ul#editable_tdm').sortable({
    // axis: 'y',
    connectWith: '.livre_tdm'
  })

  $('ul#pages_et_titres_out').sortable({
    // axis: 'y',
    connectWith: '.livre_tdm'
  })
})
