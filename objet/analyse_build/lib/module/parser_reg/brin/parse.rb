# encoding: UTF-8
=begin

  Module principal de parsing du fichier brins

=end
class AnalyseBuild
class Film
class Brin

  def parse
    @id = lines.first
    @id.numeric? || raise('La première ligne devrait contenir l’ID numérique du brin.')
    @id = @id.to_i

    @titre = lines[1].nil_if_empty
    @titre != nil || raise("Il faut impérativement définir le titre du Brin ##{@id}.")

    @description = lines[2..-1].join("\n").nil_if_empty

  end


  # Les lignes de l'élément
  def lines
    @lines ||= code.strip.gsub(/\r/,'').split("\n").collect{|n| n.strip}
  end

end #/Brin
end #/Film
end #/AnalyseBuild
