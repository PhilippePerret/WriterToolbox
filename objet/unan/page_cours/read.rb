# encoding: UTF-8
=begin

Méthodes pour l'affichage de la page

=end

class Unan
class Program
class PageCours

  # Obtenir un lien pour afficher la page, l'éditer ou
  # la détruire
  def output options = nil
    titre.in_h2 + read
  end

end #/PageCours
end #/Program
end #/Unan
