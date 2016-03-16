# encoding: UTF-8
class Cnarration
class Page

  # BIT 1
  # Le type de la page
  def type
    @type ||= options[0].to_i
  end

  # BIT 2
  # Détermine le niveau de développement, de 1 à 9
  # 9 = Page achevée
  # 8 = Lecteur finale
  # 7 = Page à corriger par le rédacteur
  # 6 = Page à relire par le lecteur
  # 0 = Page tout juste créée
  def developpement
    @developpement ||= options[1].to_i
  end

end #/Page
end #/Cnarration
