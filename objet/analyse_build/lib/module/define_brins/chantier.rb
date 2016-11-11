# encoding: UTF-8
=begin

Extension de la classe AnalyseBuild pour la définition des brins

=end
class AnalyseBuild

  def form_define_brins
    (
      'set_define_brins'.in_hidden(name: 'operation') +
      brins_as_choosable_list   +
      scenes_as_list_containers +
      explication_define_brins  +
      bouton_soumettre_new_brins
    ).in_form(id:'form_define_brins', action: "analyse_build/#{film.id}/treate")
  end
  # Liste des scènes prêtes à définir les brins
  # Chaque div contient un champ hidden qui consigne la liste des
  # brins de la scène. Ce champ est incrémenté dès qu'on glisse un
  # brin sur une scène.
  def scenes_as_list_containers
    scenes.collect do |hscene|
      hscene[:brins_ids] ||= Array.new
      scene_id = hscene[:id]
      hidden_file_id = "scene-#{scene_id}-brins"
      # debug "brins scène #{scene_id} : #{hscene[:brins_ids].inspect}"
      (
        hscene[:brins_ids].join(' ').in_span(id:"scene-#{scene_id}-spanbrins", class:'span_brins')+
        hscene[:resume] +
        hscene[:brins_ids].join(' ').in_hidden(id: hidden_file_id, name: hidden_file_id)
      ).in_div(class: 'scene', id: "scene-#{scene_id}")
    end.join.in_div(id: 'scenes')
  end

  # La liste des brins, comme une liste qu'on peut choisir et
  # glisser sur les scènes.
  def brins_as_choosable_list
    brins.collect do |hbrin|
      "#{hbrin[:id]} #{hbrin[:titre]}".in_div(class: 'brin', id: "brin-#{hbrin[:id]}")
    end.join.in_div(id: 'brins')
  end

  def explication_define_brins
    t = <<-HTML
    Cette édition permet de re-définir les brins pour les affiner.
    Cliquer sur une scène pour voir mieux la liste des brins (texte).
    À l'enregistrement, les données fournies seront modifiées et l'on pourra même recharger un fichier de collecte actualisé avec les nouveaux brins.
    HTML
    t.in_div(class: 'small italic')
  end

  def bouton_soumettre_new_brins
    'Enregistrer'.in_submit(class:'btn').in_div(class: 'right btns')
  end

end #/AnalyseBuild
