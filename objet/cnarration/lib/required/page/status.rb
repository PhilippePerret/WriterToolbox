# encoding: UTF-8
class Cnarration
class Page

  # En fonction du type (bit 1 des options)
  def page?           ; type == 1 end
  def sous_chapitre?  ; type == 2 end
  def chapitre?       ; type == 3 end

end #/Page
end #/Cnarration
