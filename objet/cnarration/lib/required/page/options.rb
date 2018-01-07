# encoding: UTF-8
class Cnarration
class Page

  # 1er BIT
  # =======
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

  # 2e BIT
  # ======
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

  # 3e BIT = seulement version en ligne
  # ======
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

  # 4e BIT = importance lecture
  # ======
  # Ce bit permet de définir le degré d'importance de
  # traitement de la page (au niveau de la lecture comme
  # au niveau de la correction). Ces valeurs correspondent
  # aux valeurs de state des tâches, c'est-à-dire :
  # De 0 à 2 : tache à traiter normalement (traitement normal)
  # De 3 à 5 : tâche importante (traitement important)
  # De 6 à 8 : tâche prioritaire (traitement prioritaire)
  #
  def priorite
    @priorite ||= options[3].to_i
  end

  # Dans la nouvelle version du BOA, les bits 9,10,11 servent à
  # consigner l'ID du chapitre et les bit 12,13,14 servent à
  # consigner l'ID du sous-chapitre, en base 36

end #/Page
end #/Cnarration
