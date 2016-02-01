# encoding: UTF-8
class Unan
class Program
class Work

  # La méthode qui crée la donnée
  def create
    unless data2save.has_key?(:created_at)
      data2save.merge!( created_at: NOW )
    end
    @id = table.insert( data2save )
  end

  # Sauvegarde de toutes les données du travail
  # Normalement, ne doit pas être utilisé, car toutes les
  # données après création sont enregistrées de façon
  # séparées par 'set'
  def save
    table.set( id, data2save )
  end

  # ---------------------------------------------------------------------
  #   Data bdd
  # ---------------------------------------------------------------------
  def abs_work_id ; @abs_work_id  ||= get(:abs_work_id) end
  def status      ; @status       ||= get(:status)||0   end
  def options     ; @options      ||= get(:options)||"" end
  def ended_at    ; @ended_at     ||= get(:ended_at)    end
  def created_at  ; @created_at   ||= get(:created_at)  end
  def updated_at  ; @updated_at   ||= get(:updated_at)  end

  def data2save
    @data2save ||= {
      program_id:   program.id  ,
      abs_work_id:  abs_work_id ,
      status:       status      ,
      options:      options     ,
      updated_at:   NOW
    }
  end
  # Pour définir les données à enregistrer à la création
  def data2save= hdata; @data2save = hdata end

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
    @duree_relative ||= begin
      raise "La donnée `program` du work ##{id} (d'abs-work ###{abs_work_id}) ne devrait pas être nil" if program.nil?
      raise "Le coefficiant de durée du programme ne devrait pas être nil" if program.coefficient_duree.nil?
      raise "L'abs-work ##{abs_work_id} ne devrait pas être nil" if abs_work.nil?
      raise "La durée de l'abs-work ##{abs_work_id} ne devrait pas être nil" if abs_work.duree.nil?
      (program.coefficient_duree * abs_work.duree.days).to_i
    end
  end

  # {Fixnum} Fin attendue, en seconde, en fonction de la date
  # de départ du travail et la durée relative.
  def expected_end
    @expected_end ||= ( created_at + duree_relative )
  end

  # Type du travail au format humain (vient de abs_work)
  def human_type
    @human_type ||= abs_work.human_type_w
  end

  # ---------------------------------------------------------------------
  #   Data provenant des options
  # ---------------------------------------------------------------------

end #/Work
end #/Program
end #/Unan
