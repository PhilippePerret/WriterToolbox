# encoding: UTF-8
=begin
  Module principal pour construire l'évènemencier du film à
  partir des données marshalisées

=end
class AnalyseBuild

  # = main =
  #
  # Méthode principale construisant l'évènemencier
  def build_events
    scenes_file.exist? || begin
      error "Le fichier des données de scènes n'existe pas. Impossible de construire un évènemencier."
      return
    end
    debug "data_scenes : #{data_scenes.pretty_inspect}"
  end



  def data_scenes
    @data_scenes ||= Marshal.load(scenes_file.read)
  end

end
