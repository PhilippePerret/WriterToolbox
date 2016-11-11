# encoding: UTF-8
class AnalyseBuild

  # Toutes les scènes récupérées.
  #
  # TODO Plus tard, on pourra en faire des instances permettant
  # de les manipuler facilement
  def scenes
    @scenes ||= begin
      if scenes_file.exist?
        Marshal.load(scenes_file.read)
      else
        Array.new
      end
    end
  end

  def brins
    @brins ||= begin
      if brins_file.exist?
        Marshal.load(brins_file.read)
      else
        Array.new
      end
    end
  end

  def personnages
    @personnages ||= begin
      if personnages_file.exist?
        Marshal.load(personnages_file.read)
      else
        Array.new
      end
    end
  end

end #/AnalyseBuild
