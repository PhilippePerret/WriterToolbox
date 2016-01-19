# encoding: UTF-8
class Unan
class Program
class Work


  # Return TRUE si le travail est en dépassement de temps, i.e.
  # s'il aurait dû être fini avant
  def depassement?
    (self.created_at + self.duree_relative) > NOW
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
