# encoding: UTF-8
=begin

Class Program (Unan::Program)
------------------------------
Instance d'un programme UN AN suivi par un auteur.

Note : À la fin de ce module est définie la méthode `program` qui
permet d'obtenir l'instance du programme courant.

=end
class Unan
class Program

  # Instance Unan::Program::Cal du calendrier du programme
  # de l'auteur courant.
  def cal
    @cal ||= Cal::new(self)
  end

  # Nombre jours total pour le programme en fonction du
  # rythme choisi (moyenne = 5, le nombre est de 365)
  def nombre_jours
    @nombre_jours ||= (365.to_f * (5.0 / rythme)).to_i
  end

  def start
    @start ||= Time.new(NOW.year, NOW.month, NOW.day).to_i
  end
  def end
    @end ||= start + ((DUREE_ANNEE_VIRTUELLE / rythme) + 1).days
  end

end
end
