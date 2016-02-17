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
  def developpement
    @developpement ||= options[1].to_i
  end

end #/Page
end #/Cnarration
