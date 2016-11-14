# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class << self

  # Renvoie le prochain numéro de scène
  def numero_courant
    @next_numero ||= 0
    @next_numero += 1
  end

end #/<< self
end #/Scene
end #/Film
end #/AnalyseBuild
