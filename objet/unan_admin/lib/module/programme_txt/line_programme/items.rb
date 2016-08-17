# encoding: UTF-8
class LineProgramme

  # Les lignes enfant de la ligne courante
  def items
    @items ||= Array.new
  end

  # Ajout de la ligne +iline+ ({LineProgramme}) à la ligne
  # courante qui devient son parent.
  # 
  def add_item iline
    iline.parent = self
    self.items << iline
  end

end #/LineProgramme
