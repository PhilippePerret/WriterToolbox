if(undefined == window.STdm){window.STdm = {}}

$.extend(window.STdm, {

  // Méthode pour n'afficher que les chapitres
  only_chapitres:function(){
    $('div#tdm > div.inner_chapitre').hide();
  },
  show_chapitres:function(){
    $('div#tdm > div.inner_chapitre').show();
  },
  only_sous_chapitres:function(){
    this.show_chapitres();
    $('div#tdm > div > div.inner_sous_chapitre').hide();
  },
  show_sous_chapitres:function(){
    this.show_chapitres();
    $('div#tdm > div.inner_sous_chapitre').show();
  },

  show_all: function(){
    this.show_sous_chapitres();
  }
})
