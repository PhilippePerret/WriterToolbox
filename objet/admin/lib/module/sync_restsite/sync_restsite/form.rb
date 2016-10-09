# encoding: UTF-8
=begin

  Module des méthodes de fabrication du formulaire pour définir
  l'opération (choix des applications, opération demandée)

=end
class SyncRestsite
class << self

  def fieldset_choix_applications
    (#débug form
      ''.in_hidden(id: 'operation', name: 'operation') +
      (
        'Source'      .in_td(class:'center bold') +
        'Destination' .in_td(class:'center bold') +
        'Opération'   .in_td(class:'center bold')
      )+
      (
        menu_apps_source.in_td +
        menu_apps_destination.in_td +
        liste_boutons_synchro.in_td(class: 'buttons')
      ).in_tr
    ).in_table.in_form(action: 'admin/sync_restsite', id: 'form_sync_restsite')

  end
  def menu_apps_source
    menu_apps(:source)
  end
  def menu_apps_destination
    menu_apps(:destination)
  end
  def liste_boutons_synchro
    bouton_submit( 'Comparer', 'compare') +
    bouton_submit('Synchroniser', 'synchronize')
  end

  # ---------------------------------------------------------------------
  #   Méthodes helper de routine
  # ---------------------------------------------------------------------
  def menu_apps sel_id
    select_id = "app_#{sel_id}".to_sym
    APPLICATIONS.collect do |kapp, dapp|
      [kapp, dapp[:hname]]
    end.in_select(id: "menu_apps_#{sel_id}", name: "#{select_id}", selected: param(select_id))
  end

  def bouton_submit name, ope
    name.in_submit(onclick: "set_operation('#{ope}')", class: 'btn small').in_div
  end

end #/<< self
end #/SyncRestsite
