# encoding: UTF-8
=begin

  Un fichier d'analyse déposé par un user dans son dossier temporaire

=end
class AnalyseBuild
class File

  # Pour parser le fichier
  #
  def parse
    # Il faut charger le module en fonction du type du fichier
    AnalyseBuild.require_module "parser_#{format}"
    _parse
  end

  # Pour reparser le fichier
  # Ça consiste à détruire les fichiers marshal et à reparser
  # le fichier
  def reparse
    Dir["#{chantier.folder}/*.msh"].each{|p| File.unlink(p)}
    parse
  end


end #/File
end #/AnalyseBuild
