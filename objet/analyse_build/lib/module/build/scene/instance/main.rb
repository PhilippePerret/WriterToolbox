# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  attr_reader :numero, :resume
  attr_reader :effet, :lieu, :decor
  attr_reader :data_paragraphes

  # Instanciation.
  # Cette méthode écrase les méthodes précédentes
  def initialize data
    @data
    data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

  def paragraphes_as_instances
    @paragraphes_as_instances ||= begin
      data_paragraphes.collect do |dparagraphe|
        AnalyseBuild::Film::Scene::Paragraphe.new(dparagraphe)
      end
    end
  end

  def left
    @left ||= chantier.film.left_of(time)
  end
end #/Scene
end #/Film
end #/AnalyseBuild
