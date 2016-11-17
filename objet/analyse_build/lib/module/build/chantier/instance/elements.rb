# encoding: UTF-8
class AnalyseBuild

  # Retourne l'instance AnalyseBuild::Film::Scene de la scène
  # de numéro +num_scene+
  def scene num_scene
    hash_scenes_as_instances[num_scene]
  end

  # Retourne l'instance AnalyseBuild::Film::Paragraphe du paragraphe
  # d'identifiant +paragraphe_id+
  def paragraphe paragraphe_id
    hash_paragraphes_as_instances[paragraphe_id]
  end


  def scenes_as_instance
    @data_scenes ||= Marshal.load(scenes_file.read)
    @data_scenes.collect do |dscene|
      AnalyseBuild::Film::Scene.new(dscene)
    end
  end


  # Retourne un Hash contenant en clé le numéro de la scène (qui
  # sert d'identifiant) et en valeur son instance AnalyseBuild::Film::Scene
  # 
  def hash_scenes_as_instances
    @hash_scenes_as_instances ||= begin
      h = Hash.new
      scenes_as_instance.each do |sc|
        h.merge!(sc.numero => sc)
      end
      h
    end
  end


  # Retourne un Hash contenant en clé l'identifiant du paragraphe
  # et en valeur l'instance AnalyseBuild::Film::Scene::Paragraphe
  #
  def hash_paragraphes_as_instances
    @hash_paragraphes_as_instances ||= begin
      h = Hash.new
      scenes_as_instance.each do |sc|
        sc.paragraphes_as_instances.each do |paragraphe|
          h.merge!(paragraphe.id => paragraphe)
        end
      end
      h
    end
  end
end #/AnalyseBuild
