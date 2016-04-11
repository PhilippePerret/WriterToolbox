# encoding: UTF-8
class Cnarration
class Page

  # Si c'est l'administrateur, cette méthode retourne les liens
  # pour éditer le texte ou les données de la page.
  # Le lien pour éditer le texte n'est présent que si c'est vraiment
  # une page, pas un titre de chapitre/sous-chapitre
  def liens_edition_if_admin
    return "" unless user.admin?
    (
      (page? ? lien.edit_file( fullpath, { titre:"[Edit text]" }) : "") +
      "[Edit data]".in_a(href:"page/#{id}/edit?in=cnarration")
    ).in_div(class:'fright small')
  end

  # Code HTML pour le code du lien permanent
  def permanent_link
    style = "font-size:11pt;width:500px"
    (
      "Lien permanent ".in_span(class:'tiny') +
      "#{site.distant_url}/page/#{id}/show?in=cnarration".in_input_text(style:style, onfocus:"this.select()")
    ).in_div
  end
end #/Page
end #/Cnarration
