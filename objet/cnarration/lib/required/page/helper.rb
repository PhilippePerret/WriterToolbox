# encoding: UTF-8
class Cnarration
class Page

  def hletype
    @hletype ||= begin
      case stype
      when :page then "la page"
      when :chapitre, :sous_chapitre then "le #{htype}"
      end
    end
  end
  alias :lehtype :hletype

  # Si c'est l'administrateur, cette méthode retourne les liens
  # pour éditer le texte ou les données de la page.
  # Le lien pour éditer le texte n'est présent que si c'est vraiment
  # une page, pas un titre de chapitre/sous-chapitre
  def liens_edition_if_admin
    OFFLINE && user.admin? || (return '')
    (
      lien_edit_text + lien_edit_data + lien_give_code
    ).in_div(class:'btns fright small')
  end

  def lien_edit_text
    page? || (return '')
    '[Edit text]'.in_a(href: "page/#{id}/edit_text?in=cnarration", target: :new)
  end

  def lien_edit_data
    "[Edit data]".in_a(href:"page/#{id}/edit?in=cnarration", target: :new)
  end

  def lien_give_code
    tit = titre.gsub(/'/,'’')
    ref_simple      = "#{id}|#{tit}"
    ref_with_ancre  = "#{id}|ANCRE|#{tit}"
    ref_route       = "page/#{id}/show?in=cnarration"
    "[&lt;-&gt;]".in_a(onclick:"UI.clip({'Route':'#{ref_route}', 'Narration':'REF[#{ref_simple}]', 'Avec ancre':'REF[#{ref_with_ancre}]'})")
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
