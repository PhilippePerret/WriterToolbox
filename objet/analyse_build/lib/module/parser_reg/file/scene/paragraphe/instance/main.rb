# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe

  # Identifiant unique du paragraphe. Il est constitué
  # du numéro de la scène, d'un double point et d'un numéro absolu
  # Par exemple : '12:2365'
  # Cet identifiant est calculé à l'instanciation du paragraphe.
  attr_reader :id

  # Instance AnalyseBuild::Film::Scene de la scène contenant le
  # paragraphe.
  attr_reader :scene

  # Code brut du paragraphe tel qu'envoyé à l'instanciation
  attr_reader :code

  def initialize scene, code
    @scene  = scene
    @code   = code
    @errors = Array.new
    @id     = "#{scene.numero}:#{self.class.new_id}"
    # On parse immédiatement le paragraphe
    self.parse
  end

end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
