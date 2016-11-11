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
    debug "data des scenes : #{scenes.pretty_inspect}"
    flash 'La construction de l’évènemencier n’est pas encore implémentée.'
  end



end
