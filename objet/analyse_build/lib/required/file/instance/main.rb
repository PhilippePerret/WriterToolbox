# encoding: UTF-8
=begin

  Un fichier d'analyse déposé par un user dans son dossier temporaire

=end
class AnalyseBuild
class File

  attr_reader :chantier
  attr_reader :path

  def initialize chantier, path
    @chantier = chantier
    @path     = path
  end


end #/File
end #/AnalyseBuild
