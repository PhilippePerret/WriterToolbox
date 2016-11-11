# encoding: UTF-8
class AnalyseBuild

  # Tous les fichiers contenus dans le dossier temporaire de l'user pour
  # le film courant (le chantier courant).
  # RETURN une liste Array de {AnalyseBuild::File}
  #
  # Note : chaque fichier est doublé d'un fichier de données .data dont
  # on ne tient pas compte ici.
  def files
    @files ||= begin
      arr = Array.new
      Dir["#{folder_depot}/*"].each do |p|
        ::File.extname(p) != '.data' || next
        arr << AnalyseBuild::File.new(self, p)
      end
      arr
    end
  end

end #/AnalyseBuild
