# encoding: UTF-8
# encoding: UTF-8
class Video

  # Sortie de la vidéo, c'est-à-dire son code d'incrustation dans
  # la page, en fonction du type de la vidéo (youtube par défaut)
  def output
    titre.in_h2 +
    description.in_div(class:'italic small') +
    self.send("frame_#{type}".to_sym).in_div(class: 'center air') +
    liens_vers_next_and_previous
  end

  # {StringHTML} Retourne la vidéo comme lien pour visualisation
  # Tient compte du niveau de visibilité de la vidéo
  def as_li
    tit = visible? ? titre.in_a(href:"video/#{id}/show") : "#{titre} "+"(visible seulement pour #{authorized_people})".in_span(class:'tiny')
    tit.in_li(class:(visible? ? '' : 'tres discret'))
  end

  def authorized_people
    case level
    when 1 then "tout le monde"
    when 2 then "les inscrits"
    when 3 then "les abonnés"
    end
  end

  def visible?
    @is_visible ||= user.admin? || (level==1) || (level==2 && user.identified?) || (level==3 && user.subscribed?)
  end

  def frame_youtube
    ifr = <<-HTML
<iframe
  width="#{FRAME_WIDTH}"
  height="#{FRAME_HEIGHT}"
  src="https://www.youtube.com/embed/#{ref}"
  frameborder="0"
  allowfullscreen>
</iframe>
    HTML
  end

  def liens_vers_next_and_previous
    (
      lien_vers_precedente.in_span(class:'fleft', style: 'vertical-align:middle') +
      lien_vers_suivante.in_span(class:'fright', style: 'vertical-align:middle')  +
      '&nbsp;'.in_span
    ).in_div(class: 'small air')
  end
  def lien_vers_precedente
    self.previous || (return '&nbsp;')
    ('◀︎ Vidéo précédente').in_a(href:"video/#{self.previous}/show")
  end
  def lien_vers_suivante
    self.next || (return '&nbsp;')
    ('Vidéo suivante ▶︎').in_a(href:"video/#{self.next}/show")
  end

end #/Video
