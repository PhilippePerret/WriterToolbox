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
      raise "Il faut définir le path du fichier de destination HTML"
    end
  end

end #/Translator
end #/Cnarration
