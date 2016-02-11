# encoding: UTF-8
class FilmAnalyse
class << self

  def folder_manuel
    @folder_manuel ||= site.folder_objet+"analyse/manuel"
  end


  # Dossier contenant les analyses
  def folder_films
    @folder_analyses ||= begin
      d = site.folder_data+'analyse/films'
      d.build unless d.exist?
      d
    end
  end

  def folder_modules
    @folder_modules ||= folder_lib+'module'
  end

  def folder_lib
    @folder_lib ||= folder+'lib'
  end
  def folder
    @folder ||= site.folder_objet+'analyse'
  end
end #/<<self
end #/FilmAnalyse
