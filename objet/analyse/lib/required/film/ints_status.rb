# encoding: UTF-8
class FilmAnalyse
class Film

  # Retourne true si l'utilisateur courant est
  # autorisé à voir cette analyse
  def user_autorized?
    # Un administrateur ou un analyse réel peuvent toujours
    # consulter les analyses, quel que soit leur stade
    # d'avancement.
    return true if user.admin? || user.real_analyste?
    # Pour les autres utilisateurs, il faut que l'analyse
    # soit au moins lisible pour qu'ils puissent la consulter
    return true if user.subscribed? && analyse_lisible?
    # Si non, on retourne false, l'user n'est pas autorisé à
    # consulter l'analyse.
    return false
  end

end #/Film
end #/FilmAnalsye
