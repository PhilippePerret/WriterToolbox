# encoding: UTF-8
=begin

Class Unan::Program::AbsWork
----------------------------
Données absolues d'une travail du programme

=end
class Unan
class Program
class AbsWork

  include MethodesObjetsBdD

  attr_reader :id

  def initialize wid
    @id = id
  end

  # ---------------------------------------------------------------------
  #   Propriétés en base de données
  # ---------------------------------------------------------------------

  # Type complet
  # ------------
  #   BIT 1     Le type général (accomplir action, lire page cours, etc.)
  #   BIT 2-3   La cible narrative du travail (narrative_target), par exemple
  #             les personnage, ou la structure.
  def type
    @type ||= get(:type)
  end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------
  def type_general
    @type_general ||= begin
      TYPES[type[0].to_i]
    end
  end
  def narrative_target
    @narrative_target ||= begin
      bits = type[1..2]
    end
  end

end #/AbsWork
end #/Program
end #/Unan
