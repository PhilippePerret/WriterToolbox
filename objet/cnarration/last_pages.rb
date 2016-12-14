# encoding: UTF-8
=begin


  RÉFLEXION
    IL faudrait un truc qui indique quand la page a été pour la première
    fois achevée. Ça serait une date d'achèvement, donc une colonne
    `completed_at`. Cette colonne serait définie la première fois que
    la page est marquée achevée.
    
=end

class Cnarration
class << self

  # = main =
  #
  # Méthode retournant la liste des dernières pages achevées.
  #
  # Si l'utilisateur est identifié, on indique les nouvelles
  # pages depuis sa derrnière connexion.
  #
  def liste_des_dernieres_pages
    'Liste des dernières pages'
  end

end #/<< self
end #/ Cnarration
