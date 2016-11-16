# encoding: UTF-8
class AnalyseBuild
class File

  # Parse le fichier d'analyse en fonction de son type
  def parse
    AnalyseBuild.require_module "parser_#{ftype}"
    to_marshal
  rescue Exception => e
    debug e
    error "Erreur au cours du parse général : #{e.message}"
  else
    true # pour poursuivre
  end

  # Parse le fichier et enregistre toutes ses données dans un fichier
  # Marshal
  # + dans le fichier général du film contenant toutes les données
  def to_marshal
    dmarshal = Array.new
    things.each do |thing|
      dmarshal << thing.all_data
    end

    # On sauve les éléments de ce type
    # --------------------------------
    # Noter qu'ils seront également sauvés dans le fichier général
    # contenant toutes les données du film et plus.
    chantier.instance_variable_set("@#{type}s", dmarshal)
    chantier.send("save_#{type}s".to_sym)

  end

  # La liste des things (chose), instances en fonction du type contenu
  # du fichier.
  #
  # Noter que c'est lors de leur initialisation qu'on procède à leur
  # parsing.
  #
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
