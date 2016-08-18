# encoding: UTF-8
class Ranking
  # Tous les mots clés à rechercher
  KEYWORDS = [
    'écrire',
    'scénario',
    'film',
    'roman',
    'écrire un scénario',
    'écrire un roman',
    'boite à outils de l\'auteur',
    'analyse de film',
    'dramaturgie',
    'règle d\'écriture'

  ]

  # Le xième lien maximum
  NOMBRE_FOUNDS_MAX = 30 #200

  LAST_PAGE_INDEX = 3

  # Le nombre de pages maximum
  # Ne servira que si NOMBRE_FOUNDS_MAX n'est pas défini, pour définir le
  # nombre de liens maximum à afficher
  NOMBRE_PAGES_MAX      = 20
  NOMBRE_LIENS_PER_PAGE = 10

end
