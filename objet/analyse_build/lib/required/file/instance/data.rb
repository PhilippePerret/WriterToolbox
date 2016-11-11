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

  # Le file type du fichier, qui détermine comment il devra être
  # lu et compris pour être parsé.
  def ftype
    @ftype || data[:ftype]
  end

  def type
    @type ||= begin
      w1ftype = ftype.split('_').first
      case w1ftype
      when 'brins'    then :brin
      when 'persos'   then :personnage
      when 'collect'  then :scene
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

  # Format du fichier, qui peut être :reg, :tm ou :yaml
  #
  # Ce format détermine le parseur à utiliser, en permettant de
  # définir le dossier dans les modules ("parser_<format>")
  def format
    @format ||= ftype.split('_').last.to_sym
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
