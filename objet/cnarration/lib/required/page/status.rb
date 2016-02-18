# encoding: UTF-8
class Cnarration
class Page


  # Retourne TRUE si le fichier erb (semi-dynamique) est plus
  # vieux que le fichier markdown
  def out_of_date?
    path_semidyn.older_than path
  end

  # En fonction du type (bit 1 des options)
  def page?           ; type == 1 end
  def sous_chapitre?  ; type == 2 end
  def chapitre?       ; type == 3 end



end #/Page
end #/Cnarration
