# encoding: UTF-8
=begin

Module de création d'un nouveau programme

=end
class Unan
class Program
class << self

  # Création d'un nouveau programme
  # La méthode est appelée suite au paiement du programme
  # par un nouveau user
  def create

    # On crée un nouvel enregistrement pour l'user courant
    # dans la table des programmes
    data_program = {
      auteur_id:  user.id,
      etape_id:   nil,
      options:    "1" + ("0"*31), # actif
      points:     0,
      rythme:     5,
      created_at:  NOW.to_i,
      updated_at:  NOW.to_i
    }
    @program_id = Unan::table_programs.insert(data_program)
  end
end # <<self
end # /Program
end # /Unan
