# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe

  attr_reader :id
  attr_reader :texte
  attr_reader :brins
  attr_reader :personnages

  def initialize data
    @data = data
    data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
