# encoding: UTF-8
class Cnarration
class Page

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
