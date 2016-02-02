# encoding: UTF-8
=begin

Module de création d'un nouveau programme

=end
class Unan
class Program
class << self

  # Puisque `create` ci-dessous est une méthode de classe, le
  # @program_id qu'elle définit sera une variable de classe que la
  # création de projet devra lire par Unan::Program::program_id
  attr_reader :program_id

  # Création d'un nouveau programme
  # -------------------------------
  # La méthode est appelée suite au paiement du programme
  # par un nouveau user (ou par les tests lorsque l'on crée
  # un user qui suit le programme UN AN UN SCRIPT)
  def create

    # On crée un nouvel enregistrement pour l'user courant
    # dans la table des programmes
    data_program = {
      auteur_id:  user.id,
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
