# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

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
  # /full_resume

end #/Scene
end #/Film
end #/AnalyseBuild
