# encoding: UTF-8
class User
class CurrentPDay
  # Auteur du current pday
  attr_reader :auteur

  def initialize u
    @auteur = u
  end

  # ---------------------------------------------------------------------
  #   Quelques raccourcis utiles
  # ---------------------------------------------------------------------
  def pseudo      ; @pseudo     ||= auteur.pseudo   end
  def program     ; @program    ||= auteur.program  end
  def program_id  ; @program_id ||= program.id      end
  def rythme      ; @rythme     ||= program.rythme  end

  # Retourne l'indice du jour courant de l'auteur
  # dans le programme.
  def day         ; @day        ||= program.current_pday end
  alias :index :day

end #/CurrentPDay
end #/User
