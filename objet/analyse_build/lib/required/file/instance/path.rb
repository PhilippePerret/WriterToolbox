# encoding: UTF-8
class AnalyseBuild
class File

  def data_file
    @data_file ||= SuperFile.new(path + '.data')
  end

  # Fichier marshal dans lequel sont enregistrées toutes les
  # données parsées du fichier. Le noms est fonction du type
  # du fichier.
  def marshal_file
    @marshal_file ||= begin
      chantier.folder + "#{type.upcase}S.msh"
    end
  end

end #/File
end #/AnalyseBuild
