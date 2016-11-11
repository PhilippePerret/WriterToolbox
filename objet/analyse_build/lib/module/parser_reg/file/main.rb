# encoding: UTF-8
=begin

  Module principal de parsing du fichier de collecte des scènes

=end
class AnalyseBuild
class File

  # Parser le fichier en fonction de son type
  # Le parser consiste à relever ses données et à créer un fichier Marshal
  # de toutes les données, pour en faire ensuite d'autres choses.
  #
  # C'est la méthode qui procède réellement au parsing, elle est appelée
  # par la méthode #parse de AnalyseBuild::File
  #
  def _parse
    to_marshal
    case type
    when :brin        then flash "Je parse le fichier des brins"
    when :personnage  then flash "Je parse le fichier des personnages"
    when :scene       then flash "Je parse le fichier des scènes"
    end
  end

  # Parse le fichier et enregistre toutes ses données dans un fichier
  # Marshal
  def to_marshal
    dmarshal = Array.new
    things.each do |thing|
      dmarshal << thing.all_data
    end
    marshal_file.write Marshal.dump(dmarshal)
  end

  # La liste des things (chose), instances en fonction du type
  def things
    @things ||= begin
      code.strip.split("\n\n").collect do |p|
        case type
        when :brin        then AnalyseBuild::Film::Brin.new(film, p)
        when :personnage  then AnalyseBuild::Film::Personnage.new(film, p)
        when :scene       then AnalyseBuild::Film::Scene.new(film, p)
        end
      end
    end
  end

  # Le code original du fichier
  #
  # On remplace les éventuels \r\n par des \n simples
  def code
    @code ||= begin
      c = SuperFile.new(path).read
      c.gsub(/\r/, c.index("\n") ? '' : "\n")
    end
  end

end #/File
end #/AnalyseBuild