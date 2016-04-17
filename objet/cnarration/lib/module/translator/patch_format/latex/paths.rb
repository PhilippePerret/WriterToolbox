# encoding: UTF-8
class Cnarration
class Translator

  # {SuperFile} Le fichier destination qui sera construit
  # dans les sources du livre
  #
  # On construit la hiérarchie de dossier jusqu'au fichier
  # si cela est nécessaire.
  #
  def file_dest
    @file_dest ||= begin
      p = livre.latex_source_folder + "#{handler}.tex"
      p.folder.build unless p.folder.exist?
      p
    end
  end

end #/Translator
end #/Cnarration
