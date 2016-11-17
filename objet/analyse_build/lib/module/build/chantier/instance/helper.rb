# encoding: UTF-8
class AnalyseBuild

  # Méthode qui permet de produire le code pour charger une feuille de styles
  # qui se trouve dans le dossier lib/css du dossier analyse.
  # Ce code CSS est "accroché" au document produit.
  def balise_styles affixe_file
    '<style type="text/css">' +
    SuperFile.new("./objet/analyse_build/lib/css/#{affixe_file}.css").read +
    '</style>'
  end


end #/AnalyseBuild
