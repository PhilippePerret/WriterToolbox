# encoding: UTF-8
=begin

Class Unan::Program::Work
-------------------------------
Un travail du programme Un An Un Script exécuté par un auteur.
Il renvoie directement à un travail absolu dont il est l'instance
pour l'auteur.

Note : Pour voir les données absolues du travail, cf. la classe
AbsWork.
=end
class Unan
class Program
class Work

  include MethodesObjetsBdD

  def initialize wid

    @id = wid

  end

  # Après un enregistrement de points, ou l'auteur qui
  # stipule que le travail est terminé, on peut
  # voir si on le passe au travail suivant
  def passer_au_suivant?
    return false if completed? == false
  end

  # Retourne TRUE si le travail est valide et que l'auteur
  # peut passer au travail suivant
  def completed?

    # TODO Voir si le travail a été effectué (il faut que
    # l'auteur le stipule explicitement)

    # TODO Toutes les pages du cours doivent avoir été lues
    # SInon => Proposer de lire les pages non lues

  end
end #/Work
end #/Program
end #/Unan
