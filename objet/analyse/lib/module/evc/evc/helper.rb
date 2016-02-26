# encoding: UTF-8
class Evc

  # +options+
  #   duree:      Si true, la durée est ajoutée si elle existe
  #   notes:      Si true, on ajoute les notes qui existent 
  def as_ul options = nil
    (
      events.collect{|ev| ev.as_li(options)}.join
    ).in_ul(class:"evc")
  end

end #/Evc
