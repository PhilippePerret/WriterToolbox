# encoding: UTF-8
=begin

Méthodes et définitions pour les options

=end
class Unan
class Program

  # BIT 1 (0)     Actif(1) ou Inactif(0)
  def activite
    @activite ||= options[0].to_i
  end
  def inactif?  ; activite == 0 end
  def actif?    ; activite == 1 end

  # BIT 2 (1)     PAUSE
  def pause     ; @pause ||= options[1].to_i end
  def pause?    ; pause == 1 end

  # BIT 3 (index 2) ABANDON (0: pas abandonné)
  def abandon   ; @abandon ||= options[2].to_i end
  def abandon?  ; abandon == 1 end


end #/Program
end #/Unan
