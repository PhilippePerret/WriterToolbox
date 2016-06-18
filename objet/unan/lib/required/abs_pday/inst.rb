# encoding: UTF-8
=begin

Données absolues d'un jour-programme (p-day)

=end
class Unan
class Program
class AbsPDay

  include MethodesMySQL

  # ID du P-Day absolu, qui sert aussi d'indice du jour 1-start.
  # Par exemple, le 12e jour porte l'ID 12
  attr_reader :id

  def initialize pday_id
    @id = pday_id
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def titre       ; @titre        ||= get(:titre)       end
  def description ; @description  ||= get(:description) end

  # Suivant le format as qui peut être :
  #   :as_data      Comme dans la base, c'est-à-dire un string des
  #                 identifiant séparés par des espaces
  #   :as_ids       {Array de Fixnum} Liste des identifiants des AbsWork
  #   :as_instance  {Array d'instances} Retourne la liste des
  #                 instances Unan::Program::AbsWork.
  def works as = :as_data
    @works ||= get(:works) || ""
    case as
    when :as_data
      # Comme enregistré dans la base de donnée, c'est-à-dire un
      # String avec les IDs séparés par espaces.
      @works
    when :as_ids, :as_id
      # Une liste de Fixnum
      @works_as_ids ||= @works.split(' ').collect{ |wid| wid.to_i }
    when :as_instances, :as_instance
      # Une liste d'instances Unan::Program::AbsWork
      @works_as_instances ||= @works.split(' ').collect do |wid|
        Unan::Program::AbsWork::new(wid)
      end
    end
  end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------
  def works_ids   ; @works_ids  ||= works.split(' ')  end


  # La table "absolute_works" dans la base de données du programme
  def table
    @table ||= Unan.table_absolute_pdays
  end

end
end
end
