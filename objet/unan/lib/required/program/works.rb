# encoding: UTF-8
=begin
Extension des instance Unan::Program pour gérer les instances
Work du programme
=end
class Unan
class Program

  # {Unan::Program::Work} Retourne l'instance d'identifiant +wid+
  # du Work du programme courant, ou nil si elle n'existe pas
  def work wid
    wid = wid.nil_if_empty.to_i_inn
    return nil if wid.nil?
    Work::get(self, wid)
  end

end #/Program
end #/Unan
