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

  include MethodesObjetsBdD

  # Index du PDay, de 1 (premier jour) à 365 (dernier jour)
  # Noter que ça correspond donc à l'index/id de l'AbsWork.
  attr_reader :id

  # {Unan::Program} Instance du programme qui possède ce P-Day
  # Toujours précisé à l'instanciation
  attr_reader :program

  def initialize program, index
    @program  = program
    @id       = index
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
  def created_at  ; @created_at ||= get(:created_at)  end
  def updated_at  ; @updated_at ||= get(:updated_at)  end

  # Enregistre toutes les données du P-Day du programme
  #
  # Pour le moment, la méthode n'est utilisée que lorsqu'on
  # crée ce p-day, c'est-à-dire lorsque le programme de l'auteur
  # passe à ce jour-programme
  def save
    data2save.merge!(created_at: NOW) if new?
    table.insert( data2save )
  end

  def new?
    table.count(where:{id: id}) == 0
  end

  def data2save
    @data2save ||= {
      id:           id,
      program_id:   program_id,
      status:       status || 1,
      points:       points || 0,
      updated_at:   NOW
    }
  end
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
  # Noter que c'est la méthode `program.table_pdays` qui doit être
  # impérativement invoquée pour pouvoir construire la table
  # quand elle n'existe pas.
  def table
    @table ||= program.table_pdays
  end

end #/PDay
end #/Program
end #/Unan
