# encoding: UTF-8
=begin

Extension de la classe AnalyseBuild pour la définition des brins

=end
class AnalyseBuild

  # Liste des scènes prêtes à définir les brins
  # Chaque div contient un champ hidden qui consigne la liste des
  # brins de la scène. Ce champ est incrémenté dès qu'on glisse un
  # brin sur une scène.
  def scenes_as_list_containers
    scenes.collect do |hscene|
      hscene[:brins] ||= Array.new
      scene_id = hscene[:id]
      debug "brins scène #{scene_id} : #{hscene[:brins].inspect}"
      (
        hscene[:brins].join(' ').in_span(id:"scene-#{scene_id}-spanbrins", class:'span_brins')+
        hscene[:resume] +
        hscene[:brins].join(' ').in_hidden(id: "scene-#{scene_id}-brins")
      ).in_div(class: 'scene', id: "scene-#{scene_id}")
    end.join.in_div(id: 'scenes')
  end

  # La liste des brins, comme une liste qu'on peut choisir et
  # glisser sur les scènes.
  def brins_as_choosable_list
    brins.collect do |hbrin|
      "#{hbrin[:id]} #{hbrin[:titre]}".in_div(class: 'brin', id: "brin-#{hbrin[:id]}")
    end.join#.in_div(id: 'brins')
  end

end #/AnalyseBuild
