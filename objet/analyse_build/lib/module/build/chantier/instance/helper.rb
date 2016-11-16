# encoding: UTF-8
class AnalyseBuild


  def bouton_rebuild_all_fichiers
    'Reconstruire les fichiers'.in_a(href: "analyse_build/#{film.id}/depot?operation=rebuild_fichiers")
  end

end#/AnalyseBuild
