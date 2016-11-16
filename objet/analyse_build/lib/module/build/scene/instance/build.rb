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

  # Intitulé de la scène
  def intitule
    @intitule ||= begin
      "#{numero}.".in_span(class: 'numero') +
      "#{lieu}".in_span(class: 'lieu') +
      "#{decor}".in_span(class:'decor') +
      ' – ' +
      "#{effet}".in_span(class: 'effet')
    end
  end

  # Le résumé de la scène
  # On prend soi celui qui est défini en première ligne soit la compilation
  # de tous les paragraphes.
  def full_resume
    @full_resume ||= begin
      if resume.nil?
        data_paragraphes.collect do |dparagraphe|
          dparagraphe[:texte]
        end.join(' ')
      else
        resume
      end
    end
  end
end #/Scene
end #/Film
end #/AnalyseBuild
