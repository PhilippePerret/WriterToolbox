# encoding: UTF-8
class Unan
class Program
class StarterPDay

  # ---------------------------------------------------------------------
  #   Raccourcis pour les données du programme
  # ---------------------------------------------------------------------
  def auteur ; @auteur ||= program.auteur end
  alias :user :auteur
  # {Fixnum} Indice du jour-programme courant
  def current_pday ; @current_pday ||= auteur.program.current_pday end
  def current_pday= valeur ; @current_pday = valeur end
  # {Fixnum} Indice du jour-programme suivant, celui affecté
  def next_pday ; @next_pday    ||= current_pday + 1 end
  def next_pday= valeur ; @next_pday = valeur end

  # {Unan::Program::AbsPDay}
  def abs_pday  ; @abs_pday     ||= Unan::Program::AbsPDay::new(next_pday)    end

end #/StarterPDay
end #/Program
end #/Unan
