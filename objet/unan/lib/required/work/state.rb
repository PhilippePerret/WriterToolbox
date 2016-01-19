# encoding: UTF-8
class Unan
class Program
class Work

  # Return TRUE si le travail existe dans la table du programme
  # false dans le cas contraire.
  def exist?
    table.count(where:{id: id}) > 0
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
