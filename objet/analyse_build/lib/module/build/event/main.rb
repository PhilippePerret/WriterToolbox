# encoding: UTF-8
=begin

  Module principal de la construction de l'évènemencier tiré
  des données (seulement si le fichier de collect des scènes a été
  fourni)

=end
class AnalyseBuild

  def build_events
    begin
      build_event
      build_chemin_de_fer
    rescue Exception => e
    end
  end

  def build_event
    suivi '** Construction des évènemenciers…'

    code =
      'Séquencier'.in_h4 +
      balise_styles('events') +
      listing_scenes_as_event.in_div(class: 'events')

    scenes_html_file.write code
  end

  def build_chemin_de_fer
    suivi '** Construction du chemin de fer…'
    code =
      'Chemin de fer'.in_h4 +
      balise_styles('chemin_de_fer') +
      listing_scenes_as_chemin_de_fer.in_div(class: 'chemin_de_fer')

    scenes_html_file.append code
  end

  # ---------------------------------------------------------------------
  #   Les méthodes de construction des évènemenciers et similaires
  # ---------------------------------------------------------------------
  # Listing des évènements pour l'évènemencier
  def listing_scenes_as_event
    scenes_as_instance.collect do |scene|
      scene.as_event
    end.join("\n")
  end

  def listing_scenes_as_chemin_de_fer
    scenes_as_instance.collect do |scene|
      scene.as_chemin_de_fer
    end.join("\n")
  end

  # /fin de méthodes de construction des évènemenciers
  # ---------------------------------------------------------------------

end
