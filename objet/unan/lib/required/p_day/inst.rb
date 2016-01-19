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
    @program    = program
    @program_id = program.id
    @id         = index
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  # def start (pour recherche)
  def points      ; @points     ||= get(:points)      end
  def program_id  ; @program_id ||= program.id        end
  def status      ; @status     ||= get(:status)      end
  def created_at  ; @created_at ||= get(:created_at)  end
  alias :start :created_at
  def updated_at  ; @updated_at ||= get(:updated_at)  end

  # Enregistre toutes les données du P-Day du programme
  # pour créer la donnée
  def create
    table.insert( data2save )
  end

  def new?
    table.count(where:{id: id}) == 0
  end

  # On part du principe qu'on n'utilise cette méthode que lorsque
  # l'on crée la donnée pour la première fois. Donc on met la
  # propriété created_at (qui posait problème avant lorsque de la
  # création, sans que je sache pourquoi)
  def data2save
    @data2save ||= {
        id:           id,
        program_id:   program_id,
        status:       status || 1,
        points:       points || 0,
        updated_at:   NOW,
        created_at:   NOW
      }
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
