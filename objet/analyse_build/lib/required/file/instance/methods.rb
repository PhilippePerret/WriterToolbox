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


end #/File
end #/AnalyseBuild
