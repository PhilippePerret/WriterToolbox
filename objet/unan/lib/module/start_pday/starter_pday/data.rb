# encoding: UTF-8
class Unan
class Program
class StarterPDay

  # ---------------------------------------------------------------------
  #   Raccourcis pour les données du programme
  # ---------------------------------------------------------------------
  def auteur        ; @auteur       ||= program.auteur                end
  # {Fixnum} Indice du jour-programme courant
  def current_pday  ; @current_pday ||= auteur.get_var(:current_pday) end
  # {Fixnum} Indice du jour-programme suivant, celui affecté
  def next_pday     ; @next_pday    ||= current_pday + 1              end

  # {Unan::Program::AbsPDay}
  def abs_pday      ; @abs_pday     ||= Unan::Program::AbsPDay::new(next_pday)    end
  # {Unan::Program::PDay}
  def pday          ; @pday         ||= Unan::Program::PDay::new(program, next_pday) end

  # {Array of Fixnum} Liste des IDs des travaux.
  # Dans un premier temps ne contient que les travaux actuels, puis
  # sera augmentée des nouveaux travaux s'il y en a
  def work_ids      ; @work_ids     ||= auteur.get_var(:works_ids)    end
  # Instances Unan::Program::Work des travaux du program
  def works         ; @works        ||= (work_ids||Array::new).collect { |wid| program.work(wid) } end
  def nombre_travaux_courants ; @nombre_travaux_courants ||= work_ids.count end

end #/StarterPDay
end #/Program
end #/Unan
