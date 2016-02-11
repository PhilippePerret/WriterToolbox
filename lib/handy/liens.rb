# encoding: UTF-8
=begin

Extension de la classe Lien, pour l'application courante

Rappel : c'est un singleton, on appelle les méthodes par :

    lien.<nom méthode>[ <args>]

=end
class Lien

  # Lien vers la partie analyse de films
  def analyses_de_films titre = "analyses de films", options = nil
    build("analyse/home", titre, options)
  end
  alias :analyses :analyses_de_films

end
