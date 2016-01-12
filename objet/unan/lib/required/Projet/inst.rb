# encoding: UTF-8
=begin

Class Unan::Projet
------------------
Gestion des projets des programmes

Note : on peut obtenir le projet du programme en faisant program.projet
=end

class Unan
class Projet

  attr_reader :id

  def initialize pid
    @id = pid.to_i
  end

  # ---------------------------------------------------------------------
  #   Données
  # ---------------------------------------------------------------------
  def auteur_id     ; @auteur_id  ||= get(:auteur_id)   end
  def program_id    ; @program_id ||= get(:program_id)  end
  def titre         ; @titre      ||= get(:titre) || "Projet ##{id}" end
  def specs         ; @specs      ||= get(:specs)       end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  # Instance {User} de l'auteur du projet
  def auteur
    @auteur ||= User::get(auteur_id)
  end
  # Instance {Unan::Program} du programme du projet
  def program
    @program ||= Unan::Program::get(program_id)
  end

  # Type du projet
  # C'est le premier BIT des specs
  def type
    @type ||= specs[0].to_i
  end

  # ---------------------------------------------------------------------

  def table
    @table ||= Unan::table_projets
  end
  
end # /Projet
end # /Unan
