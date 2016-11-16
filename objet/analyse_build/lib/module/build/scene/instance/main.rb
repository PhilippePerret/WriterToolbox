# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # Instanciation.
  # Cette méthode écrase les méthodes précédentes
  def initialize data
    @data
    data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

end #/Scene
end #/Film
end #/AnalyseBuild
