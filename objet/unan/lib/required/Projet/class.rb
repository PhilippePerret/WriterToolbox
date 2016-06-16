# encoding: UTF-8
=begin

Class Unan::Projet
------------------
Méthodes de classe

=end
class Unan
class Projet
  class << self

    # {Unan::Projet} Retourne le projet courant de l'auteur
    # d'identifiant auteur_id
    def get_current_projet_of auteur_id
      res = Unan::table_projets.select(where:"auteur_id = '#{auteur_id}'", order: "created_at DESC", limit:1, colonnes:[]).first
      if res.nil?
        debug "AUCUN PROJET N'A ÉTÉ TROUVÉ POUR L'AUTEUR"
        debug "PROJETS TROUVÉS : "
        debug Unan::table_projets.select.inspect
      end
      res.nil? ? nil : new(res[:id])
    end



  end # << self
end #/Projet
end #/Unan
