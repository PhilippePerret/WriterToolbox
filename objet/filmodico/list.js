if(undefined==window.Filmodico){window.Filmodico = {}}

$.extend(window.Filmodico,{
  gotoletter:function(ancre){
    window.location.hash = ancre ;
  },

  current_letter: "A",
  current_panneau_id:function(){return "panneau_" + this.current_letter},

  show_panneau:function(letter){
    $('section#'+this.current_panneau_id()).hide();
    $('a#letter'+this.current_letter).removeClass('active')
    this.current_letter = letter ;
    $('section#'+this.current_panneau_id()).show();
    $('a#letter'+this.current_letter).addClass('active')
  }
})
