# encoding: UTF-8
=begin

Extension des liens pour la section des analyses de film
Attention, ces liens ne sont utilisables que si l'objet `analyse`
est chargé (site.require_objet('analyse')).
Si un lien doit être accessible depuis n'importe où, comme le lien
`analyses_films` alors il faut le définir dans le fichier :
  ./lib/required/app/handy/liens.rb
=end
class Lien

  # Retourne un lien pour rejoindre l'exposition du protocole
  # d'analyse.
  #
  # @usage : lien.protocole_analyse_film("TITRE")
  def protocole_analyse_film titre = nil, options = nil
    titre ||= "protagoniste d'analyse de film"
    build("manuel/rediger?in=analyse&manp=analyse/protocole", titre, options)
  end

  # Pour rejoindre le collecteur en ligne
  # @usage lien.outil_collecte("TITRE")
  def outil_collecte titre = nil, options = nil
    titre ||= "outil de collecte en ligne"
    build("analyse/collecteur", titre, options)
  end

  # Pour trouver le bundle TextMate
  # @usage: lien.bundle_textmate_analyse("TITRE")
  def bundle_textmate_analyse titre = nil, options = nil
    titre ||= "bundle TextMate d'analyse de film"
    build("http://www.github.com/philippeperret", titre, options)
  end

end
