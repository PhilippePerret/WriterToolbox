# encoding: UTF-8
class Unan
class Projet
  class << self

    # On crée un nouveau enregistrement pour un projet
    # Rappel : il y a d'un côté le programme Unan::Program et de
    # l'autre le projet Unan::Projet développé au cours de ce
    # programme.
    def create
      program_id = user.program_id

      data_new_projet = {
        auteur_id:  user.id,
        program_id: program_id,
        titre:      nil,
        resume:     nil,
        typeP:      0,
        sharing:    0,
        created_at: NOW.to_i
      }
      require './objet/unan/projet/edit.rb'
      projet_id = create_with data_new_projet

      user.program.set(projet_id: projet_id)

      return projet_id
    end
  end # << self
end #/Projet
end #/Unan
