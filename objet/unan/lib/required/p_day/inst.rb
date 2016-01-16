# encoding: UTF-8
=begin

Instances Unan::Program::PDay
--------------
Gestion des jours de programme, les "p-day".

Principes généraux
------------------
    - Un p-day est absolu, il décrit le jour-programme de façon absolue,
      quel que soit l'auteur et le rythme.

=end
class Unan
class Program
class PDay

  # Index du PDay, de 1 (premier jour) à 365 (dernier jour)
  # Noter que ça correspond donc à l'index de l'AbsWork.
  attr_reader :id

  # {Unan::Program} Instance du programme qui possède ce P-Day
  # Toujours précisé à l'instanciation
  attr_reader :program

  def initialize program, index
    @program  = program
    @index    = index
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  # def start (pour recherche)
  def created_at  ; @created_at ||= get(:created_at)  end
  alias :start :created_at
  def points      ; @points     ||= get(:points)      end
  def program_id  ; @program_id ||= get(:program_id)  end
  def status      ; @status     ||= get(:status)      end
  def updated_at  ; @updated_at ||= get(:updated_at)  end

  # RETURN true si le nombre de points pour le p-day est
  # suffisant (pday.points = absolute_pday.minimum_points)
  def enough_points?

    # TODO Le nombre de points pour l' doit être
    # suffisant
    # SINON : Proposer de reprendre des questionnaires, à
    # commencer par les questionnaires de connaissance.
    # Rappel : pour trouver les questions de connaissance,
    # on fait "WHERE id IN (<liste id étape>) AND type LIKE '__1%'"
    # ATTENTION : "1" n'est peut-être plus le type "Connaissance",
    # Mais c'est bien le 3e bit du type qu'il faut tester.

  end

  # Table contenant tous les p-days de ce programme
  def table
    @table ||= program.database.table('pdays')
  end

end #/PDay
end #/Program
end #/Unan
