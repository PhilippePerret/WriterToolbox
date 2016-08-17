# encoding: UTF-8
class LineProgramme

  def items; @items || Array.new end

  # Ajout de la ligne +iline+ ({LineProgramme}) à la ligne
  # courante qui devient son parent.
  #
  def add_item iline
    @items ||= Array.new
    @items << iline
    iline.parent = self
  end

end #/LineProgramme
