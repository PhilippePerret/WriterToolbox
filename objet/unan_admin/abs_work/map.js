if(undefined==window.MapWorks){window.MapWorks = {}}

$.extend(window.MapWorks, {

  current_work_id: null,
  working: false,

  // ON referme le travail (cela correspondà détruire le clone ouvert)
  close_work:function(wid){
    $('div#awork-'+wid+"-clone").remove();
  },
  open_work:function(ev){
    var div_work_id = $(this).attr('data-id');
    // Le div du travail
    var work_id = 'awork-'+div_work_id;
    var clone_id = 'awork-'+div_work_id+'-clone';
    var clone_jid = 'div#'+clone_id;
    var o = $('div#awork-'+div_work_id);
    var oclone = o.clone();
    oclone.addClass('collapsed');
    oclone.attr('id', oclone.attr('id') +'-clone')
    $('div#abs_work_map').append(oclone);
  },

  // Pour placer les observeurs qui vont réagir au click
  // sur un travail, pour changer son style et pouvoir l'afficher
  observe_works:function(){
    $('div.work').bind('mouseup', MapWorks.open_work);
  },

  prepare_interface: function(){
    this.observe_works();
  }
})
Object.defineProperties(window.MapWorks, {

})
$(document).ready(function(){
  window.MapWorks.prepare_interface();
})
