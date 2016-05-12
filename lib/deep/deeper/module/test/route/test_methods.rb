# encoding: UTF-8
=begin

  Méthodes de test pour les routes

  @usage

      test_route "la/route" do |r|

        r.<methode>[ <paramètres>]
        r.<methode>[ <paramètres>]
        etc.

      end

=end
class SiteHtml
class Test
class Route


  def respond
    if request(request_only_header).ok?
      return "La page existe."
    else
      raise "La page n'existe pas."
    end
  end

  # Produit un succès si la page contient le tag
  # défini par {String} +tag+ et {hash} +hdata+
  def has_tag tag, hdata

  end

  # Produit un succès si la page contient le titre
  # +titre+ de niveau +niveau_titre+ s'il est fourni.
  # Raise une failure dans le cas contraire
  def has_title titre, niveau_titre = nil
    tag = niveau_titre ? "h#{niveau_titre}" : "h"
    titre_init = titre.instance_of?(Regexp) ? titre.source : titre
    titre = Regexp::escape( titre ) unless titre.instance_of?(Regexp)
    found = code_page.match(/<(#{tag})(?:.*?)>(.*?)<\/(\1)>/).to_a[2]
    unless found == nil
      found = ( found.match titre )
    end
    if found
      "Le titre #{tag} “#{titre_init}” existe dans la page."
    else
      raise "Le titre #{tag} “#{titre_init}” est introuvable dans la page."
    end
  end

end #/Route
end #/Test
end #/SiteHtml
