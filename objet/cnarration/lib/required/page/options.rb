# encoding: UTF-8
class Cnarration
class Page

  # BIT 1
  # Le type de la page, pour savoir si c'est une vrai page ou
  # un chapitre ou sous-chapitre.
  #
  # Un chapitre ou sous-chapitre s'appelle aussi une page car
  # il s'affiche aussi sur une page dans le livre en ligne.
  #
  # Cf. aussi `htype`
  def type
    @type ||= options[0].to_i
  end

  # BIT 2
  #
  # Détermine le niveau de développement, de 1 à 'a'
  # 10 = Page achevée (mais c'est en 'a', base 11)
  # 9  = Page achevée
  # 8  = Lecteur finale
  # 7  = Page à corriger par le rédacteur
  # 6  = Page à relire par le lecteur
  # 1  = Page tout juste créée
  # 0  = Donnée initiée
  def developpement
    @developpement ||= options[1].to_i(11)
  end

  # BIT 3 - seulement version en ligne
  #
  # Détermine si la page doit être imprimée par la
  # collection ou si c'est seulement une page pour
  # la version en ligne.
  #
  # Quand le bit est à 1 c'est seulement une version
  # en ligne
  #
  # Cette option permet de calculer les statistiques et
  # également de sortir la version papier de la collection
  #
  def printed_version
    @printed_version ||= options[2].to_i
  end

end #/Page
end #/Cnarration
