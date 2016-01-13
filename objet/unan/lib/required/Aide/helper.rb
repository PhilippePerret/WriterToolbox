# encoding: UTF-8
class Unan
class Aide
  class << self

    # Pour l'affichage du titre, du sous-titre et d'un lien
    # permettant de rejoindre la table des matières
    # @usage    <%= Unan::Aide::titre("<sous titre>") %>
    def titre sous_titre
      "<h1>Aide “Un An Un Script”</h1>"   +
      "<h2>#{sous_titre}</h2>"            +
      "Table des matières".in_a(class:'small', href:"aide/home?in=unan").in_div(class:'right small')
    end

  end # << self
end #/Aide
end #/Unan
