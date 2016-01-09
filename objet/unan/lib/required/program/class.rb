# encoding: UTF-8
class Unan
class Program
  class << self

    # {Unan::Program|NilClass} Retourne le dernier programme suivi
    # par l'auteur d'id +auteur_id+ donc certainement son programme
    # courant. Puisque l'auteur ne peut avoir qu'un seul programme
    # courant à la fois, on fait une recherche sur le programme actif.
    # Noter que c'est une instance Unan::Program qui est retournée,
    # ou NIL si aucun programme n'a été trouvé
    def get_current_program_of auteur_id
      program_id = Unan::table_programs.select(where:"auteur_id = #{auteur_id} AND options LIKE '1%'", colonnes:[:id]).values.first
      return nil if program_id.nil? # Aucun programme trouvé
      program_id = program_id[:id].freeze
      new(program_id)
    end

    # {Hash de Hash} Retourne tous les programmes de l'auteur
    # d'ID +auteur_id+
    # En clé, l'id du programme et en valeur le hash des données
    # enregistrées dans la table 'programs'
    def get_programs_of auteur_id
      Unan::table_programs.select(where:"auteur_id = #{auteur_id}")
    end

  end # << self
end # /Program
end # /Unan