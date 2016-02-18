# encoding: UTF-8
class Cnarration
class Page

  # = main =
  #
  # Méthode principale qui sort le contenu de la page
  def output
    unless path_semidyn.exist?
      # La page semi-dynamique n'est pas encore construite, il
      # faut la construire.
      (site.folder_objet+"unan_admin/lib/module/page_cours/module_build_methods.rb").require
      extend MethodesBuildPageSemiDynamique
      build_page_semi_dynamique
    end
    if path_semidyn.exist?
      path_semidyn.deserb
    else
      error "Un problème a dû survenir, je ne trouve pas la page à afficher (semi-dynamique)."
    end
  end

  # Si c'est l'administrateur, cette méthode retourne les liens
  # pour éditer le texte ou les données de la page.
  def liens_edition_if_admin
    return "" unless user.admin?
    (
      lien.edit_file(fullpath, {titre:"Edit text"}) +
      "Edit data".in_a(href:"page/#{id}/edit?in=cnarration")
    ).in_div(class:'fright small')
  end
end #/Page
end #/Cnarration
