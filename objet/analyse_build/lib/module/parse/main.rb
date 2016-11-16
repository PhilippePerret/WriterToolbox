# encoding: UTF-8
class AnalyseBuild

  # = main =
  #
  # Méthode principale qui parse les fichiers après les avoir
  # chargés.
  #
  def parse
    suivi '* Parsing des fichiers transmis…'
    [:personnages, :brins, :scenes].each do |type|
      suivi "** Parsing du fichier de type #{type}…"
      sf = self.send("#{type}_depot_file".to_sym)
      if sf.exist?
        File.new(self, sf.path).parse
      end
    end
  end

end #/AnalyseBuild
