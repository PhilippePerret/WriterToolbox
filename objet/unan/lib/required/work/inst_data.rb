# encoding: UTF-8
class Unan
class Program
class Work


  # ---------------------------------------------------------------------
  #   Data bdd
  # ---------------------------------------------------------------------
  def abs_work_id ; @abs_work_id  ||= get(:abs_work_id) end
  def abs_pday    ; @abs_pday     ||= get(:abs_pday)    end
  def status      ; @status       ||= get(:status)||0   end
  def options     ; @options      ||= get(:options)||"" end
  def ended_at    ; @ended_at     ||= get(:ended_at)    end
  def created_at  ; @created_at   ||= get(:created_at)  end
  def updated_at  ; @updated_at   ||= get(:updated_at)  end

  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------
  # {Unan::Program::AbsWork} Le travail absolu auquel fait référence
  # ce travail d'auteur.
  def abs_work
    @abs_work ||= Unan::Program::AbsWork.new(abs_work_id)
  end

  # L'auteur qui possède ce travail
  # Noter que le travail ne contient pas de propriété @user_id,
  # mais seulement @program_id
  def auteur
    @auteur ||= program.auteur
  end

  # ---------------------------------------------------------------------
  #   Raccourcis pour les données du travail absolu
  # ---------------------------------------------------------------------
  def item_id   ; @item_id      ||= abs_work.item_id    end

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

  # ---------------------------------------------------------------------
  #   Data provenant des options
  # ---------------------------------------------------------------------

end #/Work
end #/Program
end #/Unan
