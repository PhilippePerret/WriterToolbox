# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # Retourne la scène comme un évènement pour évènemencier
  def as_event
    (
      horloge     .in_span(class: 'horloge')  +
      intitule    .in_span(class: 'intitule') +
      full_resume .in_span(class: 'resume')
    ).in_div(class: 'scene')
  end

  # Retourne la scène pour un chemin de fer
  def as_chemin_de_fer
    (
      "#{horloge}"    .in_span(class: 'horloge') +
      "#{numero}."    .in_span(class: 'numero') +
      full_resume     .in_span(class: 'resume')
    ).in_div(class: 'scene')
  end

  # La scène pour un affichage dans un brin
  def as_brin_event
    "#{full_resume}#{human_infos}#{bloc_timeline}"
  end

  def bloc_timeline
    ''.in_div(class:'btm', style: "left:#{left}px")
  end


  # Intitulé de la scène
  def intitule
    @intitule ||= begin
      [
        "#{numero}.".in_span(class: 'numero'),
        "#{lieu}".in_span(class: 'lieu'),
        "#{decor}".in_span(class:'decor'),
        '–',
        "#{effet}".in_span(class: 'effet')
      ].join(' ')
    end
  end

  # Information sur la scène, ajoutées par exemple à la fin
  # du résumé écrit comme un évènement dans un séquencier ou un brin
  def human_infos
    " (#{horloge}, scène #{numero})".in_span(class: 'infos')
  end

end #/Scene
end #/Film
end #/AnalyseBuild
