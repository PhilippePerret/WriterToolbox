# encoding: UTF-8
=begin

Extension de la classe AnalyseBuild pour la définition des brins

=end
class AnalyseBuild

  def scenes_as_list_containers
    scenes.collect do |hscene|
      hscene[:resume].in_div(class: 'scene')
    end.join.in_div(id: 'scenes')
  end

end #/AnalyseBuild
