# encoding: UTF-8
class Unan
class Aide

  # Carte des liens symboliques.
  #
  # @usage
  #   Il suffit d'utiliser la clé en premier argument de
  #   la méthode `Unan::lien_aide` (ou `Unan::link_help`)
  #   Par exemple : `Unan::lien_aide(:overview, "Tout découvrir du programme !")`
  SYMBOLS_MAP = {
    overview: {titre: "Présentation", relpath: "overview/home"},
    bureau:   {titre:"bureau de travail", relpath:"fonctionnement/bureau"}
  }


end # /Aide
end # /Unan
