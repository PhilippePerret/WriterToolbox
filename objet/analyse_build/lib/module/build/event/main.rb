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
    suivi '** Construction de l’évènemencier…'

    code =
      balise_styles('events') +
      listing_scenes_as_event.in_div(class: 'events')

    scenes_html_file.write code
  end

  def build_chemin_de_fer
    suivi '** Construction du chemin de fer…'
    code =
      balise_styles('chemin_de_fer') +
      listing_scenes_as_event.in_div(class: 'events')

    scenes_html_file.append code
  end

  # Méthode qui permet de produire le code pour charger une feuille de styles
  # qui se trouve dans le dossier lib/css du dossier analyse.
  # Ce code CSS est "accroché" au document produit.
  def balise_styles affixe_file
    '<style type="text/css">' +
    SuperFile.new("./objet/analyse_build/lib/css/#{affixe_file}.css").read +
    '</style>'
  end


  # Listing des évènements pour l'évènemencier
  def listing_scenes_as_event
    scenes_as_instance.collect do |scene|
      scene.as_event
    end.join("\n")
  end

  def scenes_as_instance
    @data_scenes ||= Marshal.load(scenes_file.read)
    @data_scenes.collect do |dscene|
      AnalyseBuild::Film::Scene.new(dscene)
    end
  end
end
