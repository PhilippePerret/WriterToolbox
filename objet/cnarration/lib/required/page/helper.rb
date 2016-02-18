# encoding: UTF-8
class Cnarration
class Page

  # = main =
  #
  # Méthode principale qui sort le contenu de la page
  def output
    if false == path_semidyn.exist? || out_of_date?
      # La page semi-dynamique n'est pas encore construite, il
      # faut la construire. Pour ça, on utilise kramdown.
      (site.folder_objet+'cnarration/lib/module/page/build.rb').require
      build
    end
    if path_semidyn.exist?
      path_semidyn.deserb.in_div(id:'page_cours')
    else
      error "Un problème a dû survenir, je ne trouve pas la page à afficher (semi-dynamique)."
    end
  end

  # Si c'est l'administrateur, cette méthode retourne les liens
  # pour éditer le texte ou les données de la page.
  def liens_edition_if_admin
    return "" unless user.admin?
    (
      lien.edit_file( fullpath, { titre:"Edit text" }) +
      "Edit data".in_a(href:"page/#{id}/edit?in=cnarration")
    ).in_div(class:'fright small')
  end
end #/Page
end #/Cnarration
