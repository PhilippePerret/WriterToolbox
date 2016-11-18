# encoding: UTF-8
class AnalyseBuild


  def film?
    @film_id != nil
  end
  
  def collect_scenes_provided?
    @collect_scenes_is_provided === nil && @collect_scenes_is_provided = scenes_file.exist?
    @collect_scenes_is_provided
  end

  def collect_brins_provided?
    @collect_brins_is_provided === nil && @collect_brins_is_provided = brins_file.exist?
    @collect_brins_is_provided
  end

end #/AnalyseBuild
