# encoding: UTF-8
class Video

  FRAME_WIDTH   = 560
  FRAME_HEIGHT  = 315

  attr_reader :id
  attr_reader :titre
  attr_reader :date     # "Mois. Année"
  attr_reader :ref      # :youtube
  attr_reader :level    # 1:seulement abonnés, 2:tous

  # +data+
  #   ref:    Référence de la vidéo (video_id sur youtube)
  #   type:   Type (:youtube par défaut)
  def initialize data
    data.each{|k,v|instance_variable_set("@#{k}", v)}
  end

  # Sortie de la vidéo, c'est-à-dire son code d'incrustation dans
  # la page, en fonction du type de la vidéo (youtube par défaut)
  def output
    titre.in_h2 +
    description.in_div(class:'italic small') +
    self.send("frame_#{type}".to_sym).in_div(class: 'center air')
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
    @is_visible ||= user.admin? || (level==1) || (level==2 && user.identified?) || (level==3 && user.suscribed?)
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

  def type
    @type ||= :youtube
  end

end #/Video
