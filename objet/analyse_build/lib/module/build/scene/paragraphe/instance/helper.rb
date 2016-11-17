# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe

  def as_brin_event
    "#{texte}#{human_infos}#{bloc_timeline}"
  end

  # Information sur le paragraphe, ajoutées par exemple à la fin
  # du paragraphe écrit comme un évènement dans un séquencier ou un brin
  def human_infos
    " (#{scene.horloge}, scène #{numero_scene})".in_span(class: 'infos')
  end

  def bloc_timeline
    ''.in_div(class:'btm', style: "left:#{left}px")
  end

end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
