# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  def parse_first_line
    @horloge,
    @lieu_effet,
    @decor,
    @resume,
    @brins_ids = first_line.split("\t")
    @lieu, @effet = @lieu_effet.split(' ')
    horloge_to_time
  end

  # Transforme l'horloge en temps
  def horloge_to_time
    sec, mns, hrs = @horloge.split(':').reverse
    @time = sec.to_i + mns.to_i * 60 + hrs.to_i * 3600
  end

end #/Scene
end #/Film
end #/AnalyseBuild
