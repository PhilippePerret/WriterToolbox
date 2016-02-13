# encoding: UTF-8
=begin

Extension de la classe Lien, pour l'application courante

Rappel : c'est un singleton, on appelle les méthodes par :

    lien.<nom méthode>[ <args>]

=end
class Lien

  # Lien vers le programme UN AN UN SCRIPT
  def programme_un_an_un_script titre = nil, options = nil
    titre ||= "programme #{UN_AN_UN_SCRIPT}"
    build('unan/home', titre, options)
  end

  # Lien vers la partie analyse de films
  # @usage : <%= lien.analyses %> ou <%= lien.analyses_de_films %>
  def analyses_de_films titre = "analyses de films", options = nil
    build("analyse/home", titre, options)
  end
  def analyses titre = "analyses", options = nil
    analyses_de_films titre, options
  end

  # Liste complète et détaillée des outils
  def outils titre = "liste des outils", options = nil
    build("tool/list", titre, options)
  end

  def cnarration titre = "Collection Narration", options = nil
    build("cnarration/home", titre, options)
  end

  def forum titre = "forum", options = nil
    build('forum/home', titre, options)
  end
  def forum_de_discussion titre = "forum de discussion", options = nil
    forum titre, options
  end

end
