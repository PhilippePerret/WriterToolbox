# encoding: UTF-8
class AnalyseBuild
class Film
class Scene
class Paragraphe


  def numero_scene
    @numero_scene ||= begin
      id.split(':')[0].to_i
    end
  end

  # Instance {AnalyseBuild::Film::Scene} de la scène
  def scene
    @scene ||= chantier.scene(numero_scene)
  end

  def time
    @time ||= scene.time
  end

  # Décalage gauche dans la timeline des brins (principalement)
  def left
    @left ||= chantier.film.left_of(time)
  end


end #/Paragraphe
end #/Scene
end #/Film
end #/AnalyseBuild
