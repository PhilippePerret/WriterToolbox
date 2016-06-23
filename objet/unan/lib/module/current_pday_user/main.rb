# encoding: UTF-8
class User
class CurrentPDay
  # Auteur du current pday
  attr_reader :auteur

  def initialize u
    @auteur = u
  end

  # Raccourcis
  def program; @program ||= auteur.program end

  # Retourne l'indice du jour courant de l'auteur
  # dans le programme.
  def day
    program.current_pday
  end
  alias :index :day

end #/CurrentPDay
end #/User
