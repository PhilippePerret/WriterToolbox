# encoding: UTF-8
class Filmodico

  TIMELINE_WIDTH = 600
  # Pour décaler la timeline vers la droite
  TIMELINE_LEFT   = 40

  def left_of secs
    TIMELINE_LEFT + secondes_to_pixels(secs)
  end
  
  def secondes_to_pixels secs
    (secs.to_f * coefficiant_pixels_per_secondes).to_i
  end

  def coefficiant_pixels_per_secondes
    @coefficiant_pixels_per_secondes || TIMELINE_WIDTH.to_f / duree
  end

end#/Filmodico
