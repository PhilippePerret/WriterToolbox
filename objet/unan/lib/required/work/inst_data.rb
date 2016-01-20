# encoding: UTF-8
class Unan
class Program
class Work

  # La méthode qui crée la donnée
  def create
    table.insert(data2save.merge(created_at: NOW))
  end

  # Sauvegarde de toutes les données du travail
  # Normalement, ne doit pas être utilisé, car toutes les
  # données après création sont enregistrées de façon
  # séparées par 'set'
  def save
    table.set(id, data2save)
  end

  # ---------------------------------------------------------------------
  #   Data bdd
  # ---------------------------------------------------------------------
  def abs_work_id ; @abs_work_id  ||= get(:abs_work_id) end
  def status      ; @status       ||= get(:status)||0   end
  def options     ; @options      ||= get(:options)||"" end
  def created_at  ; @created_at   ||= get(:created_at)  end
  def updated_at  ; @updated_at   ||= get(:updated_at)  end

  def data2save
    @data2save ||= {
      program_id:   program.id,
      abs_work_id:  abs_work_id,
      status:       status,
      options:      options,
      updated_at:   NOW
    }
  end

  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------
  # {Unan::Program::AbsWork} Le travail absolu auquel fait référence
  # ce travail d'auteur.
  def abs_work
    @abs_work ||= Unan::Program::AbsWork::get(abs_work_id)
  end

  # {Fixnum} Durée relative du travail en secondes en
  # fonction du rythme courant du programme.
  def duree_relative
    @duree_relative ||= (program.coefficient_duree * abs_work.duree.days).to_i
  end

  # ---------------------------------------------------------------------
  #   Data provenant des options
  # ---------------------------------------------------------------------

end #/Work
end #/Program
end #/Unan
