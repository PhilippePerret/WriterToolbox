# encoding: UTF-8
# class AnalyseBuild
class Filmodico

  # Le temps de démarrage du film, en fonction du temps de la
  # première scène.
  # Noter que ce temps n'est utilisé que lors du parsing du fichier
  # de collect.
  # Cette donnée est définie dans le fichier :
  # ./objet/analyse_build/lib/module/parser_reg/file/scene/parse.rb
  # lors du parse du fichier de collecte des scènes.
  attr_accessor :start_time

end #/Film
# end #/AnalyseBuild
