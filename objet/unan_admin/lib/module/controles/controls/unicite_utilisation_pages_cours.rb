# encoding: UTF-8
class UnanAdmin
class Control
class << self

  # Méthode qui vérifie qu'une page de cours ne soit bien
  # utilisée qu'une seule fois par un travail.
  # Dans le cas contraire, une erreur serait produite puisque
  # chaque page ne peut avoir qu'un seul enregistrement dans
  # la table des pages de cours de l'user (user_page_courts_<id user>)
  def unicite_utilisation_pages_cours

    # Pour conserver la liste des pages déjà mentionnées
    used_pages = Hash.new
    # On passe en revue tous les travaux. On ne considère que
    # les travaux qui sont une lecture de page.
    Unan.table_absolute_works.select.each do |hwork|
      hwork[:type_w] == 20 || hwork[:type_w] == 21 || next
      item_id = hwork[:item_id]
      if used_pages.key?(item_id)
        used_pages[item_id] << hwork[:id]
      else
        used_pages.merge!(item_id => [hwork[:id]])
      end
    end

    # On fait l'affichage du résultat en affichant les erreurs
    # trouvées
    nombre_erreurs = 0
    used_pages.each do |item_id, arr_work_ids|
      arr_work_ids.count > 1 || next
      nombre_erreurs += 1
      linked_item_id = item_id.to_s.in_a(href:"page_cours/#{item_id}/edit?in=unan_admin", target: :new)
      linked_works =
        arr_work_ids.collect do |wid|
          wid.to_s.in_a(href: "abs_work/#{wid}/edit?in=unan_admin", target: :new)
        end.pretty_join
      log "# La page ##{linked_item_id} est utilisée par les travaux #{linked_works}".in_div(class: 'red bold')
    end

    nombre_erreurs > 0 || log("Aucune erreur n'a été trouvée.".in_div(class: 'blue retrait2'))
  end

end #/<< self
end #/Control
end #/UnanAdmin
