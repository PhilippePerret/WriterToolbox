# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe
class << self

  def new_id
    @last_id ||= 0
    @last_id += 1
  end
  
end #/<< self
end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
