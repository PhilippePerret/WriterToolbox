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

    # On crée un nouveau enregistrement pour un projet
    # Rappel : il y a d'un côté le programme Unan::Program et de
    # l'autre le projet Unan::Projet développé au cours de ce
    # programme.
    data_new_projet = {
      auteur_id:  user.id,
      program_id: @program_id,
      titre:      nil,
      resume:     nil,
      typeP:      0,
      sharing:    0,
      created_at: NOW.to_i
    }
    require './objet/unan/projet/edit.rb'
    projet_id = Unan::Projet::create_with data_new_projet

    new(@program_id).set(projet_id: projet_id)

    return @program_id # notamment pour les tests
  end
end # <<self
end # /Program
end # /Unan
