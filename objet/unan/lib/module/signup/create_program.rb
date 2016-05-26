# encoding: UTF-8
=begin

Module de création d'un nouveau programme

=end
class Unan
class Program
class << self

  # Puisque `create` ci-dessous est une méthode de classe, le
  # @program_id qu'elle définit sera une variable de classe que la
  # création de projet pourra lire par Unan::Program::program_id
  attr_reader :program_id

  # Création d'un nouveau programme
  # -------------------------------
  # La méthode est appelée suite au paiement du programme
  # par un nouveau user (ou par les tests lorsque l'on crée
  # un user qui suit le programme UN AN UN SCRIPT)
  #
  # +auteur+ Instance User de l'auteur pour lequel on fabrique
  # ce programme. Cet argument a été introduit pour gérer les
  # tests.
  def create auteur = nil

    auteur ||= user

    # On crée un nouvel enregistrement pour l'user courant
    # dans la table des programmes
    data_program = {
      auteur_id:          auteur.id,
      options:            "1" + ("0"*31), # actif
      points:             0,
      rythme:             5,
      current_pday:       1, # toujours le premier jour
      current_pday_start: NOW, # commencé maintenant
      created_at:         NOW,
      updated_at:         NOW
    }
    @program_id = Unan::table_programs.insert(data_program)
  end
end # <<self
end # /Program
end # /Unan
