# encoding: UTF-8
class Unan
class Projet
  class << self

    # On crée un nouveau enregistrement pour un projet
    # Rappel : il y a d'un côté le programme Unan::Program et de
    # l'autre le projet Unan::Projet développé au cours de ce
    # programme.
    #
    # +auteur+ Instance User de l'auteur pour lequel il faut
    # créer le projet. Introduit pour les tests, pour mieux
    # isoler.
    def create auteur = nil
      auteur ||= user
      debug "-> Unan::Projet::create (création du projet)"
      user_program_id = auteur.program_id
      debug "program_id par auteur.program_id : #{user_program_id.inspect}"
      # Au cas où… mais normalement aucun problème n'a été détecté
      program_id = Unan::Program::program_id

      if user_program_id.nil? || user_program_id != program_id
        debug "program_id par Unan::Program::program_id : #{Unan::Program::program_id.inspect}"
        debug "auteur.program_id et Unan::Program::program_id sont divergents. Je prends le second (et j'essaie de rectifier l'auteur aussi)."
        debug "user ID : #{auteur.id.inspect}"
      end
      program = Unan::Program::get(program_id)
      debug "Auteur program ID = #{auteur.id}"
      if auteur.instance_of?(User)

      end

      data_new_projet = {
        auteur_id:  auteur.id,
        program_id: program_id,
        titre:      nil,
        resume:     nil,
        typeP:      0,
        sharing:    0,
        created_at: NOW.to_i
      }
      require './objet/unan/projet/edit.rb'
      projet_id = create_with data_new_projet

      Unan::Program::get(program_id).set(projet_id: projet_id)
      # La ligne suivante pose problème quand tous les tests sont en
      # route (mais pas lorsque seule la feuille de test qui teste cette
      # méthode est jouée)
      # user.program.set(projet_id: projet_id)

      return projet_id
    end
  end # << self
end #/Projet
end #/Unan
