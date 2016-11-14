# encoding: UTF-8
=begin

  Un fichier d'analyse déposé par un user dans son dossier temporaire

=end
class AnalyseBuild
class File

  def name
    @name ||= ::File.basename(path)
  end

  def data
    @data ||= JSON.parse(data_file.read).to_sym
  end

  # Format du fichier
  # Le file type du fichier, qui détermine comment il devra être
  # lu et compris pour être parsé.
  # Les valeurs possibles sont :
  #   :tm
  #   :reg
  #   :yaml
  #
  def ftype
    @ftype || data[:ftype].to_sym
  end
  alias :format :ftype

  def type
    @type ||= begin
      case name
      when 'brins.txt'        then :brin
      when 'personnages.txt'  then :personnage
      when 'scenes.txt'       then :scene
      end
    end
  end

  def htype
    @htype ||= begin
      case type
      when :brin        then 'brin'
      when :personnage  then 'personnage'
      when :scene       then 'scène'
      end
    end
  end

  def hformat
    @hformat ||= begin
      case format
      when :reg   then 'normal (régulier)'
      when :tm    then 'textmate (bundle)'
      when :yaml  then 'YAML'
      end
    end
  end

end #/File
end #/AnalyseBuild
