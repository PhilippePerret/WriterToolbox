# encoding: UTF-8
class Unan
class Program

  # Instance {Unan::Program::CurPDay} du programme courant
  #
  # Attention : Ne pas utiliser `current_pday` qui renvoie
  # simplement l'indice du jour courant du programme.
  def cur_pday
    @cur_pday ||= Unan::Program::CurPDay::new(current_pday, auteur)
  end

end #/Program
end #/Unan
