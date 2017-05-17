# encoding: UTF-8
class Video

  FRAME_WIDTH   = 560
  FRAME_HEIGHT  = 315

  attr_reader :id
  attr_reader :titre
  attr_reader :date     # "Mois. Année"
  attr_reader :ref      # :youtube
  attr_reader :level    # 1:seulement abonnés, 2:tous
  attr_reader :next     # ID de la vidéo suivante
  attr_reader :previous # ID de la vidéo précédente
  def type ; @type ||= :youtube end

  # +data+
  #   ref:    Référence de la vidéo (video_id sur youtube)
  #   type:   Type (:youtube par défaut)
  def initialize data
    data.each{|k,v|instance_variable_set("@#{k}", v)}
  end


end #/Video
